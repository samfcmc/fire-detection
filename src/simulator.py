from TOSSIM import *
import sys

EVENTS = 5000

t = Tossim([])
r = t.radio()

nodes = {}

f = open("topo.txt", "r")
for line in f:
  s = line.split()
  if s:
    print " ", s[0], " ", s[1], " ", s[2]
    node1 = int(s[0])
    node2 = int(s[1])
    gain = float(s[2])
    r.add(node1, node2, gain)
    m1 = t.getNode(node1)
    m2 = t.getNode(node2)
    if not nodes.has_key(node1):
        nodes[node1] = m1
    if not nodes.has_key(node2):
        nodes[node2] = m1

t.addChannel("Boot", sys.stdout)
t.addChannel("Debug", sys.stdout)
t.addChannel("Messages", sys.stdout)

noise = open("noise.txt", "r")
for line in noise:
  str1 = line.strip()
  if str1:
    val = int(str1)
    for i in nodes:
        print("Adding noise trace " + str(i))
        t.getNode(i).addNoiseTraceReading(val)

for i in nodes:
  t.getNode(i).createNoiseModel()

# Boot nodes
for i in nodes:
    time = (31 + t.ticksPerSecond() / 10) * i +  1
    print("Booting node " + str(i) + " in time " + str(time))
    t.getNode(i).bootAtTime(time)


for i in range(EVENTS):
  t.runNextEvent();
