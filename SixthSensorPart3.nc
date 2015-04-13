#include <Timer.h>
#include "SixthSensorPart3.h"      
 
module SixthSensorPart3 {   

uses {    
  
    interface Boot;
    interface Packet;
    interface Mts300Sounder;
    interface Timer<TMilli> as Timer0;
    interface AMPacket;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Leds;
    interface Receive;
    interface Read<uint16_t>;
}                        

}

implementation {
  
  bool busy = FALSE;
  message_t packet;                                 //making object of message_t
  uint16_t ctr = 0;                                 //counter
  //nx_uint16_t data1;
  uint16_t LedSet=0;

event void Boot.booted() {                        //fuctions to be executed during time of boot
    call AMControl.start();
}
 
event void Timer0.fired() {                       //on firing timer, read is done
    call Read.read();
}

event void AMControl.stopDone(error_t err) {
}

event void AMControl.startDone(error_t err) {
      
      if (err == SUCCESS) {
          if (TOS_NODE_ID == 4) {
          call Timer0.startPeriodic(TIMER_PERIOD_MILLI);   //Calling the timer for node 4 to read light      
      }                                                   //sensor value
   }
      else {
          call AMControl.start();                             //Start message service
      }
   }

event void AMSend.sendDone(message_t* msg, error_t error) { //Check if packet is sent
    if (&packet == msg) {
      busy = FALSE;
    }
}

//Read sensor value on node 4

event void Read.readDone(error_t result, uint16_t data) {
    if (result == SUCCESS) {                              //If node 4, increase counter when sensor value
      if (TOS_NODE_ID == 4) {                             //below threshold and transmit packet
        if (data < 600) {
          ctr++;
          if (!busy) {
            SixthSensorPart3Msg* pkt = (SixthSensorPart3Msg*)(call Packet.getPayload
                                      (&packet,  sizeof (SixthSensorPart3Msg)));
            pkt->sensorvalue = data;                     //assigning read value to packet 
            pkt->dstid = TOS_NODE_ID - 1;                //specify destination as 3
            pkt->srcid = TOS_NODE_ID;                    //transmit packet 
            pkt->packetid = ctr;
           
            if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(SixthSensorPart3Msg)) == SUCCESS) {
              busy = TRUE;
            }
          }
        }
      }
      
    }
  }

event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {   //If packet is received
    if (len == sizeof(SixthSensorPart3Msg)) {                                      //Check if packet complete
      SixthSensorPart3Msg* pkt_tx = (SixthSensorPart3Msg*)(call Packet.getPayload  
                                (&packet,  sizeof (SixthSensorPart3Msg)));    
      SixthSensorPart3Msg* pkt_rx = (SixthSensorPart3Msg*)payload;                 
      

      if (!busy) {
        if (pkt_rx->dstid == TOS_NODE_ID) {
          //if node id 1, check received sensor value again and sound beeper if value less than threshold
          if (TOS_NODE_ID == 1) {
            if (pkt_tx->sensorvalue < 600) {
               call Mts300Sounder.beep(1000);                 //Beep sounder if value below theshold
               }
             }
          //logic for other nodes
          else {       
            LedSet=pkt_rx->packetid;            
            call Leds.set(LedSet);
            
            pkt_tx->packetid = pkt_rx->packetid;          //forward packet id 
            pkt_tx->sensorvalue = pkt_rx->sensorvalue;    //forward sensor value

            pkt_tx->srcid = TOS_NODE_ID;                  //assign source ID as our node id
            pkt_tx->dstid = TOS_NODE_ID - 1;              //assign dest ID as next node id

            //data1=pkt_rx->sensorvalue;
             
           //start transmitting
            if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(SixthSensorPart3Msg)) == SUCCESS) {
              busy = TRUE;
            }
        }
       }
      }
    }
    return msg;
  }


}
