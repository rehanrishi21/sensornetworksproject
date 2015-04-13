#include <Timer.h>
#include "SixthSensorPart3.h"                         //including library

configuration SixthSensorPart3AppC {                  //Configuration of App file
}

implementation {
  components MainC;                                   //Defining components to be used by motes
  components LedsC;
  components SounderC;
  components new DemoSensorC() as Sensor;
  components SixthSensorPart3 as App;
  components new AMSenderC(AM_SixthSensorPart3);
  components new AMReceiverC(AM_SixthSensorPart3);
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;



  App.Boot -> MainC;                                  //Making the wiring connections
  App.Leds -> LedsC;
  App.Mts300Sounder -> SounderC;
  App.AMControl -> ActiveMessageC;
  App.Packet -> AMSenderC;
  App.Read -> Sensor;
  App.AMPacket -> AMSenderC;
  App.Timer0 -> Timer0;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  
}                                                     //end of implementation
