
enum
{
	WIDTH = 100,
	HEIGHT = 100
};

module GPSP {
	provides interface GPS;
	uses interface Random;
}

implementation {

	// Return the coordinate x
	command uint16_t GPS.getX(){
		return call Random.rand16() % WIDTH;
	}

	// Return the coordinate y
	command uint16_t GPS.getY(){
		return call Random.rand16() % HEIGHT;
	}

	command void GPS.readPosition() {
		uint16_t x = call Random.rand16() % WIDTH;
		uint16_t y = call Random.rand16() % HEIGHT;
		signal GPS.positionReady(SUCCESS, x, y);
	}

}
