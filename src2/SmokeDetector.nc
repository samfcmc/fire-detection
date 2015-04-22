/*
 * Smoke Detector Interface
 */

interface SmokeDetector {
  command void boot();
  event void burning();
}
