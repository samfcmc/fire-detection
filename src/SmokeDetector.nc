/*
 * Smoke Detector Interface
 */

interface SmokeDetector {
  command void detectSmoke();
  /*
   * When there is smoke detected,
   * the smoke parameter will equals true
   * and false otherwise
   */
  event void onSmoke(error_t err, bool smoke);
}
