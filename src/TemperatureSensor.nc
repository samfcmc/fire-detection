/*
 * Temperature Sensor Interface
 */

interface TemperatureSensor {
  command void getTemperature();
  event void temperatureDone(error_t err, uint16_t value);
}
