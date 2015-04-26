/*
 * Node component
 * Use TOS_NODE_ID to know the node's id
 */

#include <Timer.h>
#include "Node.h"

module NodeP {
  uses interface Boot;

  uses interface Timer<TMilli> as Timer0;

  //Used to control messages timeout
  uses interface Timer<TMilli> as Timer1;

  uses interface GPS;
  uses interface Sensors;
  uses interface SmokeDetector;

  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;
}

implementation {

  FILE *f;

  bool busy = FALSE;
  bool firstMsg = TRUE;

  message_t pkt;
  Message *pendingMsg = NULL;
  am_addr_t routeNodeAddr;

  // Limit of sensor nodes that can be connected
  // to a routing node
  uint8_t sensorNodes = MAX_SENSOR_NODES;

  event void Boot.booted() {
    if(IS_ROUTING_NODE) {
      dbg("Boot", "Instant %d - Routing Node Booted!\n", call Timer0.getNow());
    }
    else if(IS_SENSOR_NODE) {
      dbg("Boot", "Instant %d - Sensor Node Booted!\n", call Timer0.getNow());
    }
    else {
      dbg("Boot", "Instant %d - Server Node Booted!\n", call Timer0.getNow());
      f = fopen("log.txt", "w");
      fprintf(f, "Instant %d: Server booted.\n", call Timer0.getNow());
      fclose(f);
    }
    call AMControl.start();
  }

  event void Timer0.fired() {
    call Sensors.readValues();
  }

  event void Timer1.fired() {
    if(IS_SENSOR_NODE) {
      routeNodeAddr = 0;
      dbg("Timeout", "Message timeout\n");
      call Timer0.stop();
      call SmokeDetector.turnOff();
      call GPS.readPosition();
    }
  }

  event void Sensors.valuesReady(error_t err, uint16_t temperature, uint16_t humidity) {
    Message *btrpkt;
    if(err == SUCCESS && !busy) {
      btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
      btrpkt->nodeId = TOS_NODE_ID;
      btrpkt->timestamp = call Timer0.getNow();
      btrpkt->type = MESSAGE_SENSORS;
      btrpkt->value1 = temperature;
      btrpkt->value2 = humidity;
      dbg("Sensors", "Sensors values read. Temperature: %d Humidity: %d\n", temperature, humidity);
      if (call AMSend.send(routeNodeAddr, &pkt, sizeof(Message))== SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void GPS.positionReady(error_t err, uint16_t x, uint16_t y) {
    if(err == SUCCESS && !busy) {
      Message *btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
      btrpkt-> nodeId = TOS_NODE_ID;
      btrpkt-> timestamp = call Timer0.getNow();
      btrpkt->type = MESSAGE_GPS;
      btrpkt->value1 = x;
      btrpkt->value2 = y;
      dbg("GPS", "Position read. X: %d Y: %d\n", x, y);
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void SmokeDetector.burning(){
    dbg("Fire", "FIRE ALERT\n");
    if(IS_SENSOR_NODE){
      Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
      btrpkt-> type = MESSAGE_FIRE;
      btrpkt-> nodeId = TOS_NODE_ID;
      btrpkt-> timestamp = call Timer0.getNow();
      if(busy) {
        pendingMsg = btrpkt;
        dbg("Fire", "Fire alert message is pending\n");
      }
      else {
        if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS) {
          busy = TRUE;
        }
      }
    }
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      if(IS_SENSOR_NODE) {
        call GPS.readPosition();
        dbg("Start", "Start done\n");
      }
    }
    else {
      dbg("Start", "Start failed. Trying again...\n");
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    Message *btrpkt;
    if(&pkt == msg) {
      btrpkt = (Message*) (call Packet.getPayload(&pkt, sizeof(Message)));
      busy = FALSE;
      if(IS_SENSOR_NODE) {
        dbg("MessagesSensor", "Sensor node sent message %s to %d\n", MESSAGE_TYPE(btrpkt->type), MESSAGE_DEST(msg));
        if(btrpkt->type == MESSAGE_SENSORS ||
          btrpkt->type == MESSAGE_GPS) {
            if(!call Timer1.isRunning()) {
              call Timer1.startOneShot(TIMEOUT);
            }
        }
        else if(btrpkt->type == MESSAGE_GPS_ACK) {
          call Timer0.startPeriodic(TIMER_PERIOD);
          call SmokeDetector.boot();
        }
      }
      else if(IS_ROUTING_NODE) {
        //Check for pending messages
        if(pendingMsg) {
          dbg("MessagesRouting", "Message %s from sensor node %d was pending\n", MESSAGE_TYPE(pendingMsg->type), pendingMsg->nodeId);
          btrpkt->type = pendingMsg->type;
          btrpkt->nodeId = pendingMsg->nodeId;
          btrpkt->timestamp = pendingMsg->timestamp;
          btrpkt->value1 = pendingMsg->value1;
          btrpkt->value2 = pendingMsg->value2;
          if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS) {
            busy = TRUE;
            pendingMsg = NULL;
          }
        }
      }
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    Message* received = (Message*) payload;
    if(IS_ROUTING_NODE) {
      dbg("MessagesRouting", "Routing node received message %s from sensor node %d from routing node %d\n", MESSAGE_TYPE(received->type), received->nodeId, MESSAGE_SOURCE(msg));
      if(received->type == MESSAGE_GPS && !sensorNodes) {
        // Already has 100 sensor nodes
      }
      else if(received->type == MESSAGE_GPS_ACK) {
        sensorNodes--;
      }
      else if(busy) {
        if((received->type == MESSAGE_FIRE) ||
          (received->type == MESSAGE_GPS && pendingMsg
            && pendingMsg->type != MESSAGE_FIRE)) {
          pendingMsg = received;
        }
      }
      else {
        Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt->type = received->type;
        btrpkt->nodeId = received->nodeId;
        btrpkt->timestamp = received->timestamp;
        btrpkt->value1 = received->value1;
        btrpkt->value2 = received->value2;
        if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
          busy = TRUE;
        }
      }
    }
    else if(IS_SENSOR_NODE) {
      Message* btrpkt;
      am_addr_t source = call AMPacket.source(msg);
      dbg("MessagesSensor", "Sensor node received message %s from node %d\n", MESSAGE_TYPE(received->type), source);
      if(received->type == MESSAGE_SENSORS && received->nodeId == TOS_NODE_ID) {
        // A routing node broadcasted a sensor measure message
        call Timer1.stop();
      }
      else if(received->type == MESSAGE_GPS && received->nodeId == TOS_NODE_ID && !routeNodeAddr) {
        // Routing node sends back gps coordinates of this node
        // Works like an acknowledge
        call Timer1.stop();
        routeNodeAddr = call AMPacket.source(msg);
        btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt->type = MESSAGE_GPS_ACK;
        btrpkt->nodeId = TOS_NODE_ID;
        if (call AMSend.send(routeNodeAddr, &pkt, sizeof(Message)) == SUCCESS) {
          busy = TRUE;
        }
      }
    }
    else {
      dbg("MessagesServer", "Server node received message %s from sensor node %d from routing node %d\n", MESSAGE_TYPE(received->type), received->nodeId, MESSAGE_SOURCE(msg));
      f = fopen("log.txt", "a");
      if(received->type == MESSAGE_GPS){
        fprintf(f, "Instant %d, Node %d, x=%d, y=%d.\n", received->timestamp, received->nodeId, received->value1, received->value2);
      }else if(received->type == MESSAGE_SENSORS){
        fprintf(f, "Instant %d, Node %d, Temperature=%d, Humidity=%d.\n", received->timestamp, received->nodeId, received->value1, received->value2);
      }else if(received->type == MESSAGE_FIRE){
        fprintf(f, "Instant %d, Node %d, Fire!!\n", received->timestamp, received->nodeId);
      }
      fclose(f);
    }

    return msg;
  }
}
