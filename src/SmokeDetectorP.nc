/*
 * Smoke Detector Provider
 */

module SmokeDetectorP {
  provides interface SmokeDetector;
  uses interface Random;
  uses interface Timer<TMilli> as FireTimer;
}

implementation {
	command void SmokeDetector.boot() {
    dbg("Debug", "Smoke detector booted\n");
		call FireTimer.startOneShotAt(call Random.rand16() % 1000, 0);
	}

	event void FireTimer.fired() {
    dbg("Debug", "Fire in node %d\n", TOS_NODE_ID);
		signal SmokeDetector.burning();
	}


}
