/*
 * Node component
 * Use TOS_NODE_ID to know the node's id
 */

#include <Timer.h>
#include "Node.h"

module NodeC {
  uses interface Boot;
  uses interface Timer<TMilli> as Timer0;
}

implementation {
  bool busy = FALSE;
  message_t pkt;

  event void Boot.booted() {
    dbg("Boot", "Booted\n");
  }

  event void Timer0.fired() {
    dbg("Timer", "Timer fired\n");
  }

}
