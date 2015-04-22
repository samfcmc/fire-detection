/*
 * Humidity Sensor Provider
 */

enum
{
	HUMIDITY_LIMIT = 100
};

module HumiditySensorP {
  provides interface HumiditySensor;
  uses interface Random;
}

implementation {
  command uint16_t HumiditySensor.getHumidity() {
  		return call Random.rand16() % HUMIDITY_LIMIT;
  }
}
