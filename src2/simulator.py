from TOSSIM import *
import sys

t = Tossim([])
r = t.radio()
f = open("topo.txt", "r")

for line in f:
  s = line.split()
  if s:
    print " ", s[0], " ", s[1], " ", s[2];
    r.add(int(s[0]), int(s[1]), float(s[2]))

t.addChannel("Debug", sys.stdout)

noise = open("noise.txt", "r")
for line in noise:
  str1 = line.strip()
  if str1:
    val = int(str1)
    for i in range(103):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(103):
  print "Creating noise model for ",i;
  t.getNode(i).createNoiseModel()

t.getNode(0).bootAtTime(0);
t.getNode(1).bootAtTime(5);
t.getNode(2).bootAtTime(10);
t.getNode(100).bootAtTime(15);
t.getNode(101).bootAtTime(20);
t.getNode(102).bootAtTime(25);

for i in range(500):
  t.runNextEvent();
