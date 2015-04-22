/*
 * Smoke Detector Provider
 */

module SmokeDetectorP {
  provides interface SmokeDetector;
  uses interface Random;
  uses interface Timer<TMilli> as Timer1;
}

implementation {
	command void SmokeDetector.boot() {
		call Timer1.startOneShotAt(call Random.rand16() % 1000, 0);
	}

	event void Timer1.fired() {
		signal SmokeDetector.burning();
	}


}
