/*
 * Node component
 * Use TOS_NODE_ID to know the node's id
 */

#include <Timer.h>
#include "Node.h"

module NodeP {
  uses interface Boot;

  uses interface Timer<TMilli> as Timer0;

  uses interface GPS;
  uses interface Sensors;
  uses interface SmokeDetector;

  uses interface Packet;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;
}

implementation {

  FILE *f;

  bool busy = FALSE;
  bool firstMsg = TRUE;

  message_t pkt;

  event void Boot.booted() {

    call AMControl.start();
    //call SmokeDetector.boot();

    if(IS_ROUTING_NODE) {
      dbg("Debug", "Instant %d - Routing Node Booted!\n", call Timer0.getNow());
    }
    else if(IS_SENSOR_NODE) {
      dbg("Debug", "Instant %d - Sensor Node Booted!\n", call Timer0.getNow());
    }
    else {
      dbg("Debug", "Instant %d - Server Node Booted!\n", call Timer0.getNow());
      f = fopen("log.txt", "w");
      fprintf(f, "Instant %d: Server booted.\n", call Timer0.getNow());
      fclose(f);
    }
  }

  event void Timer0.fired() {
    dbg("Debug", "Timer fired\n");
    if(!busy){
        if(firstMsg){
          firstMsg = FALSE;
          call GPS.readPosition();
        } else {
          call Sensors.readValues();
        }
    }
  }

  event void Sensors.valuesReady(error_t err, uint16_t temperature, uint16_t humidity) {
    if(err == SUCCESS && !busy) {
      Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
      btrpkt->nodeId = TOS_NODE_ID;
      btrpkt->timestamp = call Timer0.getNow();
      btrpkt->type = MESSAGE_SENSORS;
      btrpkt->value1 = temperature;
      btrpkt->value2 = humidity;
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS) {
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
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS) {
        busy = TRUE;
      }
      dbg("Debug", "Position ready\n");
    }
  }

  event void SmokeDetector.burning(){
    if(!busy && IS_SENSOR_NODE){
      Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
      btrpkt-> type = MESSAGE_FIRE;
      btrpkt-> nodeId = TOS_NODE_ID;
      btrpkt-> timestamp = call Timer0.getNow();
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      if(IS_SENSOR_NODE) {
        call Timer0.startPeriodicAt((TOS_NODE_ID % 100)*20, TIMER_PERIOD);
        dbg("Debug", "Start done\n");
      }
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&pkt == msg) {
      Message *btrpkt = (Message*) (call Packet.getPayload(msg, sizeof(Message)));
      dbg("Debug", "Instant %d - Message type %d sent!\n", btrpkt->timestamp, btrpkt->type);
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    Message* received = (Message*) payload;

    if(!busy && IS_ROUTING_NODE){
      Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
      btrpkt->type = received->type;
      btrpkt->nodeId = received->nodeId;
      btrpkt->timestamp = received->timestamp;
      btrpkt->value1 = received->value1;
      btrpkt->value2 = received->value2;
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS) {
        busy = TRUE;
      }
    }
    else if (IS_SERVER_NODE){
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
