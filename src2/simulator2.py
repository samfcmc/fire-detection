#!/usr/bin/env python

# ------------------------------------- #
# User interface for the Sensor Network #
# ------------------------------------- #

import sys;
from TOSSIM import *
from tinyos.tossim.TossimApp import *

# load the system components
n = NescApp()
t = Tossim(n.variables.variables())
m = t.mac()
r = t.radio()

# Debug channels
t.addChannel("Boot", sys.stdout)
t.addChannel("NodeC", sys.stdout)

max_nodes = 10

# add the nodes to the radio channel and boot them
for i in range(max_nodes):
	m = t.getNode(i)
	m.bootAtTime((31 + t.ticksPerSecond() / 10) * i +  1)

# create the sensor network topology
f = open("topo.txt", "r")
for line in f:
  s = line.split()
  if s:
    if s[0] == "gain":
      r.add(int(s[1]), int(s[2]), int(s[3]))

# create the noise model for each node
noise = open("noise.txt", "r")
for line in noise:
  s = line.strip()
  if s:
    val = int(s)
    for i in range(max_nodes):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(max_nodes):
  t.getNode(i).createNoiseModel()

def nothing():
    #TODO: This is just a placeholder
    return None

def small_test():
	for i in range(0, 3):
		m = t.getNode(i)
		m.bootAtTime((31 + t.ticksPerSecond() / 10) * i +  1)

	for i in range(100):
		t.runNextEvent()

def exit():
    sys.exit()

# Dictionary used by identify the functions
options = {
	1 : small_test,
	2 :	nothing,
	3 : nothing,
	4 : nothing,
	5 : nothing,
	6 : nothing,
    7 : exit,
}

print "Welcome to Fire Detection Network, the supported functionalities are :"

# Main loop

while True:
    print "1 - Small Test"
    print "2 - Nothing"
    print "3 - Nothing"
    print "4 - Nothing"
    print "5 - Nothing"
    print "6 - Nothing"
    print "7 - Exit"

    try:
        num = int(raw_input("Please, choose an option : "))
        options[num]()
    except ValueError:
        print("Please insert a valid option")
        continue
    except KeyError:
        print("There is no such option")
        continue
