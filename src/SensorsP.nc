/*
 * Sensors Provider
 */
enum {
  MAX_TEMPERATURE = 100,
  MAX_HUMIDITY = 100
};

module SensorsP {
  provides interface Sensors;
  uses interface Random;
}

implementation {
  command void Sensors.readValues() {
    uint16_t temperature = call Random.rand16() % MAX_TEMPERATURE;
    uint16_t humidity = call Random.rand16() % MAX_HUMIDITY;
    signal Sensors.valuesReady(SUCCESS, temperature, humidity);
  }
}
