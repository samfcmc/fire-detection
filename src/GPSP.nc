
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
}

