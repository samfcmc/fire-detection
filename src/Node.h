#ifndef NODE_H
#define NODE_H

enum {
  TIMER_PERIOD = 50,
  SERVER_NODE_ID = 0,
  ROUTING_NODE_MIN_ID = 1,
  ROUTING_NODE_MAX_ID = 99,
  SENSOR_NODE_MIN_ID = 100,
  AM_FIRE_DETECTION = 6,
  TIMEOUT = 200,
  MAX_SENSOR_NODES = 100,

  /*
   * Message types
   */
  MESSAGE_GPS = 0,
  MESSAGE_SENSORS = 1,
  MESSAGE_FIRE = 2,
  MESSAGE_GPS_ACK = 3
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

#define MESSAGE_TYPE(type) type == MESSAGE_GPS ? "GPS" : ( type == MESSAGE_SENSORS ? "SENSORS" : (type == MESSAGE_FIRE ? "FIRE" : (type == MESSAGE_GPS_ACK ? "GPS_ACK" : "!UNDEFINED!")))
#define MESSAGE_SOURCE(msg) call AMPacket.source(msg)
#define MESSAGE_DEST(msg) call AMPacket.destination(msg)

#endif
