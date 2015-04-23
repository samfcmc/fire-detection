/*
 * GPS Interface
 */
interface GPS{
	// implemented by the provider
	command uint16_t getX();
	command uint16_t getY();
	command void readPosition();
	event void positionReady(error_t err, uint16_t x, uint16_t y);
}
