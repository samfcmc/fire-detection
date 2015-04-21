/*
 * Node component
 * Use TOS_NODE_ID to know the node's id
 */

#include <Timer.h>
#include "Node.h"

module NodeC {
  uses interface Boot;
  uses interface Timer<TMilli> as Timer0;
  uses interface SplitControl as AMControl;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface Gps;
  uses interface HumiditySensor;
  uses interface TemperatureSensor;
  uses interface SmokeDetector;
}

implementation {
  bool busy = FALSE;
  message_t pkt;
  // Only for server node
  FILE *f;

  event void Boot.booted() {
    dbg("Boot", "Booted\n");
    call AMControl.start();
    if(IS_ROUTING_NODE) {
      dbg("Boot", "Booted routing node\n");
    }
    else if(IS_SENSOR_NODE) {
      //TODO: Connect to a routing node
      dbg("Boot", "Booted sensor node\n");
    }
    else {
      dbg("Boot", "Booted server node\n");
      f = fopen("log.txt", "w");
      writeF(f, call Timer0.getNow(), "Server booted\n");
      fclose(f);
    }
  }

  event void Timer0.fired() {
    dbg("Timer", "Timer fired\n");
  }

  event void AMControl.startDone(error_t err) {
    if(err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // Nothing to do here...
  }

  event void Gps.coordinatesDone(error_t err, uint16_t x, uint16_t y) {
    if(err == SUCCESS) {
      //TODO: Implement this...
    }
  }

  event void HumiditySensor.humidityDone(error_t err, uint16_t value) {
    if(err == SUCCESS) {
      //TODO: Implement this...
    }
  }

  event void TemperatureSensor.temperatureDone(error_t err, uint16_t value) {
    if(err == SUCCESS) {
      //TODO: Implement this
    }
  }

  event void SmokeDetector.onSmoke(error_t err, bool smoke) {
    if(err == SUCCESS) {
      //TODO: Implement this
    }
  }

  event void AMSend.sendDone(message_t *msg, error_t err) {
    if(err == SUCCESS) {
      //TODO: Implement this
    }
  }

  event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
    if(len == sizeof(FireDetectionMsg)) {
      FireDetectionMsg *btrpkt = (FireDetectionMsg*) payload;
      if(IS_ROUTING_NODE) {
        //TODO: Retransmit the message
      }
      else if(IS_SENSOR_NODE) {
        //TODO: Depends on the communication protocol
      }
      else {
        // Is server node
        //TODO: Print to file
        fprintf(f, "testing\n");
      }
    }
    return msg;
  }

}
