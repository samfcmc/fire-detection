/*
 * Humidity Sensor Interface
 */

interface HumiditySensor {
  command void getHummidity();
  event void humidityDone(error_t err, uint16_t value);
}
