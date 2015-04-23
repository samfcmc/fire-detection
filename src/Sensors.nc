/*
 * Humidity and Temperature sensors
 * Interface
 */

interface Sensors {
  command void readValues();
  event void valuesReady(error_t err, uint16_t temperature, uint16_t humidity);
}
