/*
 * Smoke Detector Provider
 */

#include "SmokeDetector.h"

module SmokeDetectorP {
  provides interface SmokeDetector;
}

implementation {
  command void SmokeDetector.detectSmoke() {
    //TODO: Detect smoke and signal event
  }
}
