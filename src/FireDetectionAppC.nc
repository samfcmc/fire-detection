#include <Timer.h>
#include "Node.h"

configuration FireDetectionAppC {

}

implementation {
  components MainC;
  components NodeC as App;

  components new TimerMilliC() as Timer0;
  components ActiveMessageC;

  components new AMSenderC(AM_FIRE_DETECTION);
  components new AMReceiverC(AM_FIRE_DETECTION);

  components GpsP;
  components HumiditySensorP;
  components TemperatureSensorP;
  components SmokeDetectorP;

  App.Boot -> MainC;
  App.Timer0 -> Timer0;

  App.AMControl -> ActiveMessageC;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;

  App.Gps -> GpsP;
  App.HumiditySensor -> HumiditySensorP;
  App.TemperatureSensor -> TemperatureSensorP;
  App.SmokeDetector -> SmokeDetectorP;
}
