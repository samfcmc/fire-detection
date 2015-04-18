/*
 * Humidity Sensor Provider
 */

#include "HumiditySensor.h"

module HumiditySensorP {
  provides interface HumiditySensor;
}

implementation {
  command void HumiditySensor.getHummidity() {
    //TODO: Get value and signal event
  }
}
