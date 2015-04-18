/*
 * Temperature Sensor Provider
 */

#include "TemperatureSensor.h"

module TemperatureSensorP {
  provides interface TemperatureSensor;
}

implementation {
  command void TemperatureSensor.getTemperature() {
    //TODO: Get value and signal event
  }
}
