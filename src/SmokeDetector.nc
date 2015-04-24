/*
 * Smoke Detector Interface
 */

interface SmokeDetector {
  command void boot();
  command void turnOff();
  event void burning();
}
