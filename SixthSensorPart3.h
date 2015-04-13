#ifndef SixthSensorPart3_H
#define SixthSensorPart3_H

enum {
  AM_SixthSensorPart3 = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct SixthSensorPart3Msg {           //Defining structure of packets to be exchanged
  nx_uint16_t srcid;
  nx_uint16_t dstid;
  nx_uint16_t packetid;
  nx_uint16_t sensorvalue;
} SixthSensorPart3Msg;                            //Making Object of structure

#endif
