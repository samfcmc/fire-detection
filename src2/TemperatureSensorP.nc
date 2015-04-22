/*
 * Temperature Sensor Provider
 */

enum
{
	MAX_TEMPERATURE = 100
};

module TemperatureSensorP {
  provides interface TemperatureSensor;
  uses interface Random;
}

implementation {
  // The temperature is measured in Kelvin
  command uint16_t TemperatureSensor.getTemperature() {
    return call Random.rand16() % MAX_TEMPERATURE;
  }
}
