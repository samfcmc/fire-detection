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

  #ifdef TOSSIM
  FILE *f;
  #endif

  bool busy = FALSE;
  bool firstMsg = TRUE;

  message_t pkt;
  Message *bufferFireMsg = NULL;
  Message *bufferGPSMsg = NULL;
  Message *bufferMsg = NULL;
  am_addr_t routeNodeAddr;

  // Limit of sensor nodes that can be connected
  // to a routing node
  uint8_t sensorNodes = MAX_SENSOR_NODES;

  uint8_t rank = 0;

  bool inNetwork = FALSE;

  event void Boot.booted() {
    if(IS_ROUTING_NODE) {
      dbg("Boot", "Instant %d - Routing Node Booted!\n", call Timer0.getNow());
    }
    else if(IS_SENSOR_NODE) {
      dbg("Boot", "Instant %d - Sensor Node Booted!\n", call Timer0.getNow());
    }
    else {
      dbg("Boot", "Instant %d - Server Node Booted!\n", call Timer0.getNow());
      #ifdef TOSSIM
      dbg("Boot", "TESTING\n");
      f = fopen("log.txt", "w");
      fprintf(f, "Instant %d: Server booted.\n", call Timer0.getNow());
      fclose(f);
      #endif
    }
    call AMControl.start();
  }

  event void Timer0.fired() {
    call Sensors.readValues();
  }

  event void Timer1.fired() {
    Message *btrpkt;
    if(IS_SENSOR_NODE) {
      dbg("Timeout", "Message timeout. Cannot reach routing node %d %s\n", routeNodeAddr, routeNodeAddr == 0 ? "UNDEFINED" : "");
      inNetwork = FALSE;
      call Timer0.stop();
      call SmokeDetector.turnOff();
      btrpkt = (Message*) (call Packet.getPayload(&pkt, sizeof(Message)));
      btrpkt->type = MESSAGE_JOIN;
      btrpkt->nodeId = TOS_NODE_ID;
      if(busy) {
        //Channel is busy
        //Trigger timer again
        call Timer1.startOneShot(TIMER_PERIOD);
      }
      else {
        if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
          busy = TRUE;
        }
      }
    }
    else if(IS_ROUTING_NODE) {
      if(!rank) {
        dbg("Timeout", "Timeout. Trying to get a new rank\n");
        btrpkt = (Message*) (call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt->type = MESSAGE_GET_RANK;
        btrpkt->nodeId = TOS_NODE_ID;
        if(busy) {
          call Timer1.startOneShot(TIMER_PERIOD);
        }
        else {
          if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
            busy = TRUE;
          }
        }
      }
      else {
        // Timeout trying to forward a message
        dbg("Timeout", "Cannot forward a message\n");
        btrpkt = (Message*) (call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt->type = MESSAGE_CANNOT_REACH_SERVER;
        btrpkt->nodeId = TOS_NODE_ID;
        btrpkt->rank = rank;
        if(busy) {
          call Timer1.startOneShot(TIMER_PERIOD);
        }
        else {
          if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
            busy = TRUE;
          }
        }
      }
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
      btrpkt->rank = 0;
      dbg("Sensors", "Sensors values read. Temperature: %d Humidity: %d\n", temperature, humidity);
      if (call AMSend.send(routeNodeAddr, &pkt, sizeof(Message))== SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void GPS.positionReady(error_t err, uint16_t x, uint16_t y) {
    if(err == SUCCESS) {
      Message *btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
      btrpkt-> nodeId = TOS_NODE_ID;
      btrpkt-> timestamp = call Timer0.getNow();
      btrpkt->type = MESSAGE_GPS;
      btrpkt->value1 = x;
      btrpkt->value2 = y;
      btrpkt->rank = rank;
      dbg("GPS", "Position read. X: %d Y: %d\n", x, y);
      if (call AMSend.send(routeNodeAddr, &pkt, sizeof(Message))== SUCCESS) {
        busy = TRUE;
        call Timer0.startPeriodic(TIMER_PERIOD);
        call SmokeDetector.boot();
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
      btrpkt->rank = rank;
      if(busy) {
        bufferFireMsg = btrpkt;
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
      Message *btrpkt;
      dbg("Start", "Start done\n");
      if(IS_SENSOR_NODE) {
        btrpkt = (Message*) (call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt->type = MESSAGE_JOIN;
        btrpkt->nodeId = TOS_NODE_ID;
        if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
          busy = TRUE;
        }
      }
      else if(IS_ROUTING_NODE) {
        btrpkt = (Message*) (call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt->type = MESSAGE_GET_RANK;
        btrpkt->nodeId = TOS_NODE_ID;
        btrpkt->rank = rank;
        if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
          busy = TRUE;
        }
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
    am_addr_t dest;
    if(&pkt == msg) {
      btrpkt = (Message*) (call Packet.getPayload(&pkt, sizeof(Message)));
      busy = FALSE;
      if(bufferFireMsg || bufferGPSMsg || bufferMsg) {
        Message *buffer;
        if(bufferFireMsg) {
          buffer = bufferFireMsg;
        }
        else if(bufferGPSMsg) {
          buffer = bufferGPSMsg;
        }
        else {
          buffer = bufferMsg;
        }
        dbg("Messages", "Message %s from sensor node %d was pending\n", MESSAGE_TYPE(buffer->type), buffer->nodeId);
        btrpkt->type = buffer->type;
        btrpkt->nodeId = buffer->nodeId;
        btrpkt->timestamp = buffer->timestamp;
        btrpkt->value1 = buffer->value1;
        btrpkt->value2 = buffer->value2;
        btrpkt->rank = buffer->rank;
        if(routeNodeAddr) {
          dest = routeNodeAddr;
        }
        else {
          dest = AM_BROADCAST_ADDR;
        }
        if (call AMSend.send(dest, &pkt, sizeof(Message))== SUCCESS) {
          busy = TRUE;
          bufferFireMsg = buffer == bufferFireMsg ? NULL : bufferFireMsg;
          bufferGPSMsg = buffer == bufferGPSMsg ? NULL : bufferGPSMsg;
          bufferMsg = buffer == bufferMsg ? NULL : bufferMsg;
        }
      }
      else if(IS_SENSOR_NODE) {
        SENT_MSG_DBG("MessagesSent", msg, btrpkt);
        if(btrpkt->type == MESSAGE_SENSORS ||
          btrpkt->type == MESSAGE_GPS ||
          btrpkt->type == MESSAGE_JOIN) {
            if(!call Timer1.isRunning()) {
              call Timer1.startOneShot(TIMEOUT);
            }
        }
        else if(btrpkt->type == MESSAGE_JOIN_ACCEPT) {
          inNetwork = TRUE;
          call GPS.readPosition();

        }
      }
      else if(IS_ROUTING_NODE) {
        SENT_MSG_DBG("MessagesSent", msg, btrpkt);
        if(btrpkt->type == MESSAGE_GET_RANK) {
          call Timer1.stop();
          call Timer1.startOneShot(TIMEOUT);
        }
        else if(btrpkt->type == MESSAGE_GPS ||
          btrpkt->type == MESSAGE_SENSORS ||
          btrpkt->type == MESSAGE_FIRE) {
            call Timer1.startOneShot(TIMEOUT);
        }
      }
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    Message *received = (Message*) payload;
    Message *btrpkt;
    if(IS_ROUTING_NODE) {
      RECEIVED_MSG_DBG("MessagesReceived", msg, received);
      if(received->type == MESSAGE_GET_RANK) {
        if(rank && !received->rank) {
          btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
          btrpkt->type = MESSAGE_RANK;
          btrpkt->nodeId = received->nodeId;
          btrpkt->rank = rank;
          if(busy) {
            bufferMsg = btrpkt;
          }
          else {
            if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
              busy = TRUE;
            }
          }
        }
      }
      else if(received->type == MESSAGE_RANK) {
        if(received->nodeId == TOS_NODE_ID) {
          if((received->value1 + 1) > rank) {
            rank = received->rank + 1;
            if(call Timer1.isRunning()) {
              call Timer1.stop();
            }
          }
        }
      }
      else if(rank) {
        /* Routing nodes can handle other kinds
         * of messages ONLY when they have a rank value
         */
        if(received->type == MESSAGE_JOIN && sensorNodes) {
          btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
          btrpkt->type = MESSAGE_JOIN_ACK;
          btrpkt->nodeId = received->nodeId;
          if(busy) {
            bufferMsg = btrpkt;
          }
          else {
            if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
              busy = TRUE;
            }
          }
        }
        else if(received->type == MESSAGE_JOIN_ACCEPT) {
          sensorNodes--;
        }
        else if(received->type == MESSAGE_SENSORS ||
          received->type == MESSAGE_FIRE ||
          received->type == MESSAGE_GPS) {
            if(call AMPacket.source(msg) == received->nodeId ||
              received->rank > rank) {
                if(busy) {
                  if(received->type == MESSAGE_FIRE) {
                    bufferFireMsg = received;
                  }
                  else if(received->type == MESSAGE_GPS) {
                    bufferGPSMsg = received;
                  }
                  else {
                    bufferMsg = received;
                  }
                }
                else {
                  btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
                  btrpkt->type = received->type;
                  btrpkt->nodeId = received->nodeId;
                  btrpkt->timestamp = received->timestamp;
                  btrpkt->value1 = received->value1;
                  btrpkt->value2 = received->value2;
                  btrpkt->rank = rank;
                  if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
                    busy = TRUE;
                  }
                }
            }
            else if(received->rank < rank) {
              if(call Timer1.isRunning()) {
                call Timer1.stop();
              }
            }
        }
        else if(received->type == MESSAGE_CANNOT_REACH_SERVER) {
          if(received->rank < rank) {
            btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
            btrpkt->type = received->type;
            btrpkt->nodeId = TOS_NODE_ID;
            btrpkt->rank = rank;
            if(busy) {
              bufferMsg = btrpkt;
            }
            else if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
              busy = TRUE;
            }
          }
        }
      }
    }
    else if(IS_SENSOR_NODE) {
      RECEIVED_MSG_DBG("MessagesReceived", msg, received);
      if(received->type == MESSAGE_SENSORS && received->nodeId == TOS_NODE_ID) {
        // A routing node broadcasted a sensor measure message
        call Timer1.stop();
      }
      else if(received->type == MESSAGE_JOIN_ACK && received->nodeId == TOS_NODE_ID && !inNetwork) {
        // Routing node sends back a join request message
        am_addr_t source = call AMPacket.source(msg);
        if(routeNodeAddr != source) {
          routeNodeAddr = source;
          dbg("MessagesReceived", "JOIN ACK %d\n", source != routeNodeAddr);
          call Timer1.stop();
          btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
          btrpkt->type = MESSAGE_JOIN_ACCEPT;
          btrpkt->nodeId = TOS_NODE_ID;
          if (call AMSend.send(routeNodeAddr, &pkt, sizeof(Message)) == SUCCESS) {
            busy = TRUE;
          }
        }
      }
      else if(received->type == MESSAGE_CANNOT_REACH_SERVER) {
        if(call AMPacket.source(msg) == routeNodeAddr) {
          // The current routing node cannot be used anymore
          // Try to find a new one
          call Timer0.stop();
          inNetwork = FALSE;
          btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
          btrpkt->type = MESSAGE_JOIN;
          btrpkt->nodeId = received->nodeId;
          btrpkt->rank = rank;
          if(busy) {
            bufferMsg = btrpkt;
          }
          else {
            if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
              busy = TRUE;
            }
          }
        }
      }
    }
    else {
      RECEIVED_MSG_DBG("MessagesReceived", msg, received);
      if(received->type == MESSAGE_GET_RANK) {
        btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt->type = MESSAGE_RANK;
        btrpkt->nodeId = received->nodeId;
        btrpkt->rank = rank;
        if(busy) {
          bufferMsg = btrpkt;
        }
        else {
          if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
            busy = TRUE;
          }
        }
      }
      else if(received->type == MESSAGE_GPS ||
        received->type == MESSAGE_FIRE ||
        received->type == MESSAGE_SENSORS){

        btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt->type = received->type;
        btrpkt->nodeId = received->nodeId;
        btrpkt->timestamp = received->timestamp;
        btrpkt->rank = rank;
        btrpkt->value1 = received->value1;
        btrpkt->value2 = received->value2;
        if(busy) {
          bufferMsg = btrpkt;
        }
        else {
          if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
            busy = TRUE;
          }
        }
        #ifdef TOSSIM
        f = fopen("log.txt", "a");
        if(received->type == MESSAGE_GPS){
          fprintf(f, "Instant %d, Node %d, x=%d, y=%d.\n", received->timestamp, received->nodeId, received->value1, received->value2);
        }else if(received->type == MESSAGE_SENSORS){
          fprintf(f, "Instant %d, Node %d, Temperature=%d, Humidity=%d.\n", received->timestamp, received->nodeId, received->value1, received->value2);
        }else if(received->type == MESSAGE_FIRE){
          fprintf(f, "Instant %d, Node %d, Fire!!\n", received->timestamp, received->nodeId);
        }
        fclose(f);
        #endif
      }
    }

    return msg;
  }
}
