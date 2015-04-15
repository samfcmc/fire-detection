interface Gps{
	// implemented by the provider
	command void getCoordinates();
	command void updateCoordinates(uint32_t time_elapsed);
	// implemented by the user
	event void coordinatesDone(error_t err, uint16_t x_coordinate, uint16_t y_coordinate);
}