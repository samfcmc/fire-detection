/*
 * GPS Interface
 */
interface GPS{
	// implemented by the provider
	command uint16_t getX();
	command uint16_t getY();
}