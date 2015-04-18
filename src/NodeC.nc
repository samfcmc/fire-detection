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
  uses interface Gps;
  uses interface HumiditySensor;
  uses interface TemperatureSensor;
  uses interface SmokeDetector;
}

implementation {
  bool busy = FALSE;
  message_t pkt;

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

}
