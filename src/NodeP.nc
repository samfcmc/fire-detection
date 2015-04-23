  /*
   * Node component
   * Use TOS_NODE_ID to know the node's id
   */

  #include <Timer.h>
  #include "Node.h"

  module NodeP {
    uses interface Boot;

    uses interface Timer<TMilli> as Timer0;

    uses interface GPS;
    uses interface HumiditySensor;
    uses interface TemperatureSensor;
    uses interface SmokeDetector;

    uses interface Packet;
    uses interface AMSend;
    uses interface SplitControl as AMControl;
    uses interface Receive;
  }

  implementation {

    FILE *f;

    bool busy = FALSE;
    bool firstMsg = TRUE;

    message_t pkt;

    event void Boot.booted() {

      call AMControl.start();
      call SmokeDetector.boot();

      if(IS_ROUTING_NODE) {
        dbg("Debug", "Instant %d - Routing Node Booted!\n", call Timer0.getNow());
      }
      else if(IS_SENSOR_NODE) {
        dbg("Debug", "Instant %d - Sensor Node Booted!\n", call Timer0.getNow());
      }
      else if(IS_SERVER_NODE) {
        dbg("Debug", "Instant %d - Server Node Booted!\n", call Timer0.getNow());
        f = fopen("log.txt", "a");
        fprintf(f, "Instant %d: Server booted.\n", call Timer0.getNow());
        fclose(f);
      }

      
    }

    event void Timer0.fired() {

      if(!busy){
          Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
          btrpkt-> nodeId = TOS_NODE_ID;
          btrpkt-> instant = call Timer0.getNow();
          if(firstMsg){
            firstMsg = FALSE;
            btrpkt-> type = 0;
            btrpkt-> x = call GPS.getX();
            btrpkt-> y = call GPS.getY(); 
          } else {
            btrpkt-> type = 1;
            btrpkt-> temperature = call TemperatureSensor.getTemperature();
            btrpkt-> humidity = call HumiditySensor.getHumidity();
          }

          if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS) {
            busy = TRUE;
            dbg("Debug", "Instant %d - Message type %d sent!\n", call Timer0.getNow(), btrpkt->type);
          }
      }
    }

    event void SmokeDetector.burning(){
      if(!busy && IS_SENSOR_NODE){
        Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
        btrpkt-> type = 2;
        btrpkt-> nodeId = TOS_NODE_ID;
        btrpkt-> instant = call Timer0.getNow();
        if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS)
        {
            busy = TRUE;
            dbg("Debug", "Instant %d - Message type %d sent!\n", call Timer0.getNow(), btrpkt->type);
        }
      }
    }

    event void AMControl.startDone(error_t err)
      {
          if (err == SUCCESS)
          {
                if(IS_SENSOR_NODE){
                  call Timer0.startPeriodicAt((TOS_NODE_ID % 100)*20, TIMER_PERIOD);
                }
          }
          else
          {
              call AMControl.start();
          }
      }

      event void AMControl.stopDone(error_t err)
      {
      }

      event void AMSend.sendDone(message_t* msg, error_t error)
      {
          if (&pkt == msg)
          {
              busy = FALSE;
          }
      }

      event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
      {
          Message* received = (Message*) payload;

          if(!busy && IS_ROUTING_NODE){

            Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof(Message)));
            btrpkt->type = received->type;
            btrpkt->nodeId = received->nodeId;
            btrpkt->instant = received->instant;
            btrpkt->x = received->x;
            btrpkt->y = received->y;
            btrpkt->temperature = received->temperature;
            btrpkt->humidity = received->humidity;
            if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message))== SUCCESS)
                  {
                      busy = TRUE;
                      dbg("Debug", "Instant %d - Message type %d sent!\n", call Timer0.getNow(), btrpkt->type);
                  }
          } else if (IS_SERVER_NODE){

            f = fopen("log.txt", "a");
            if(received->type == 0){
              fprintf(f, "Instant %d, Node %d, x=%d, y=%d.\n", received->instant, received->nodeId, received->x, received->y);
            }else if(received->type == 1){
              fprintf(f, "Instant %d, Node %d, Temperature=%d, Humidity=%d.\n", received->instant, received->nodeId, received->temperature, received->humidity);
            }else if(received->type == 2){
              fprintf(f, "Instant %d, Node %d, Fire!!\n", received->instant, received->nodeId);
            }
            fclose(f);
          }


          return msg;
      }
  }
