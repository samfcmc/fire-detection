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

t.addChannel("Boot", sys.stdout)
t.addChannel("Debug", sys.stdout)

noise = open("noise.txt", "r")
for line in noise:
  str1 = line.strip()
  if str1:
    val = int(str1)
    for i in range(103):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(103):
  t.getNode(i).createNoiseModel()

t.getNode(0).bootAtTime(0);
t.getNode(1).bootAtTime(20);
t.getNode(2).bootAtTime(40);
t.getNode(100).bootAtTime(80);
t.getNode(101).bootAtTime(100);
t.getNode(102).bootAtTime(120);

for i in range(1000):
  t.runNextEvent();
