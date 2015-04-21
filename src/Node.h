#ifndef NODE_H
#define NODE_H

enum {
  TIMER_PERIOD = 100,
  SERVER_NODE_ID = 0,
  ROUTING_NODE_MIN_ID = 1,
  ROUTING_NODE_MAX_ID = 99,
  SENSOR_NODE_MIN_ID = 100,
  AM_FIRE_DETECTION = 6
};

typedef nx_struct FireDetectionMsg {
  //TODO:
} *FireDetectionMsg;

/*
 * Helper macros to distinguish between different nodes
 */
#define IS_SERVER_NODE (TOS_NODE_ID == SERVER_NODE_ID)
#define IS_ROUTING_NODE (TOS_NODE_ID > SERVER_NODE_ID && TOS_NODE_ID < SENSOR_NODE_MIN_ID)
#define IS_SENSOR_NODE (TOS_NODE_ID > ROUTING_NODE_MAX_ID)

#endif
