#ifndef NODE_H
#define NODE_H

enum {
  TIMER_PERIOD = 100,
  SERVER_NODE_ID = 0,
  ROUTING_NODE_MIN_ID = 1,
  ROUTING_NODE_MAX_ID = 99,
  SENSOR_NODE_MIN_ID = 100,
  AM_FIRE_DETECTION = 6,

  /*
   * Message types
   */
  MESSAGE_GPS = 0,
  MESSAGE_SENSORS = 1,
  MESSAGE_FIRE = 2
};

typedef nx_struct Message {
	nx_uint8_t type; //0-Boot, 1-Timer, 2-Smoke
	nx_uint16_t nodeId;
	nx_uint32_t timestamp;
	nx_uint16_t value1;
	nx_uint16_t value2;
} Message;

/*
 * Helper macros to distinguish between different nodes
 */
#define IS_SERVER_NODE (TOS_NODE_ID == SERVER_NODE_ID)
#define IS_ROUTING_NODE (TOS_NODE_ID > SERVER_NODE_ID && TOS_NODE_ID < SENSOR_NODE_MIN_ID)
#define IS_SENSOR_NODE (TOS_NODE_ID > ROUTING_NODE_MAX_ID)

// Helper function to write to file
inline void writeF(FILE *f, uint32_t instant, char *msg) {
  fprintf(f, "Instant %d, Node %d : %s", instant, TOS_NODE_ID, msg);
}

#endif
