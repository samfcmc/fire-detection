#include "Gps.h"
#include "math.h"

module GpsP {
	provides interface Gps;
	uses interface Random;
}
implementation {

	uint16_t x;
	uint16_t y;

	uint32_t velocity = 3.0;

	// Initialize the gps coordinates
	command void Gps.getCoordinates(){
		// calculate the coordinates
		x = call Random.rand16() % WIDTH;
		y = call Random.rand16() % HEIGHT;
		// call the event to send the coordinates
		signal Gps.coordinatesDone(SUCCESS, x, y);
	}
	// Update the gps coordinates
	command void Gps.updateCoordinates(uint32_t time_elapsed){
		// update the coordinates according a animal velocity
		if(x < WIDTH){
			x += floor(velocity * time_elapsed) / 1000;
		}
		else {
			x -= floor(velocity * time_elapsed) / 1000;	
		}
		if(x < HEIGHT){
			y += floor(velocity * time_elapsed) / 1000;
		}
		else {
			y -= floor(velocity * time_elapsed) / 1000;	
		}
		// call the event to send the updated coordinates
		signal Gps.coordinatesDone(SUCCESS, x, y);
	}
}
