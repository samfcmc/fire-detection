#ifndef NODE_H
#define NODE_H

enum {
  TIMER_PERIOD = 500,
  SERVER_NODE_ID = 0,
  ROUTING_NODE_MIN_ID = 1,
  ROUTING_NODE_MAX_ID = 99,
  SENSOR_NODE_MIN_ID = 100,
  AM_FIRE_DETECTION = 6,
  TIMEOUT = 500,
  MAX_SENSOR_NODES = 100,

  /*
   * Message types
   */
  MESSAGE_GPS = 0,
  MESSAGE_SENSORS = 1,
  MESSAGE_FIRE = 2,
  MESSAGE_JOIN = 3,
  MESSAGE_JOIN_ACK = 4,
  MESSAGE_JOIN_ACCEPT = 5,
  MESSAGE_GET_RANK = 6,
  MESSAGE_RANK = 7
};

typedef nx_struct Message {
	nx_uint8_t type; //0-Boot, 1-Timer, 2-Smoke
	nx_uint16_t nodeId;
	nx_uint32_t timestamp;
  nx_uint8_t rank;
	nx_uint16_t value1;
	nx_uint16_t value2;
} Message;

/*
 * Helper macros to distinguish between different nodes
 */
#define IS_SERVER_NODE (TOS_NODE_ID == SERVER_NODE_ID)
#define IS_ROUTING_NODE (TOS_NODE_ID > SERVER_NODE_ID && TOS_NODE_ID < SENSOR_NODE_MIN_ID)
#define IS_SENSOR_NODE (TOS_NODE_ID > ROUTING_NODE_MAX_ID)

#define MESSAGE_TYPE(type) type == MESSAGE_GPS ? "GPS" : ( type == MESSAGE_SENSORS ? "SENSORS" : (type == MESSAGE_FIRE ? "FIRE" : (type == MESSAGE_JOIN ? "JOIN" : (type == MESSAGE_JOIN_ACK ? "JOIN_ACK" : (type == MESSAGE_JOIN_ACCEPT ? "JOIN_ACCEPT" : (type == MESSAGE_GET_RANK ? "GET_RANK" : (type == MESSAGE_RANK ? "RANK" : "!UNDEFINED!")))))))
#define MESSAGE_SOURCE(msg) call AMPacket.source(msg)
#define MESSAGE_DEST(msg) call AMPacket.destination(msg)

#define NODE_TYPE IS_ROUTING_NODE ? "Routing Node" : (IS_SENSOR_NODE ? "Sensor Node" : "Server Node")

#define RECEIVED_MSG_DBG(channel, msg, payload) dbg(channel, "%s <-- Message: %s Nodeid: %d From: %d Value1: %d Value2: %d Rank: %d\n", NODE_TYPE, MESSAGE_TYPE(payload->type), payload->nodeId, MESSAGE_SOURCE(msg), payload->value1, payload->value2, payload->rank)
#define SENT_MSG_DBG(channel, msg, payload) dbg(channel, "%s --> Message: %s Nodeid: %d To: %d Value1: %d Value2: %d Rank: %d\n", NODE_TYPE, MESSAGE_TYPE(payload->type), payload->nodeId, MESSAGE_DEST(msg), payload->value1, payload->value2, payload->rank)
#endif
