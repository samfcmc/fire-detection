#include <Timer.h>

configuration FireDetectionAppC {

}

implementation {
  components MainC;
  components NodeC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components GpsP;
  components HumiditySensorP;
  components TemperatureSensorP;
  components SmokeDetectorP;

  App.Boot -> MainC;
  App.Timer0 -> Timer0;
  App.AMControl -> ActiveMessageC;
  App.Gps -> GpsP;
  App.HumiditySensor -> HumiditySensorP;
  App.TemperatureSensor -> TemperatureSensorP;
  App.SmokeDetector -> SmokeDetectorP;
}
