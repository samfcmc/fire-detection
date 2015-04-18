#include <Timer.h>

configuration FireDetectionAppC {

}

implementation {
  components MainC;
  components NodeC as App;
  components new TimerMilliC() as Timer0;

  App.Boot -> MainC;
  App.Timer0 -> Timer0;
}
