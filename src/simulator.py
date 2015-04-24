from TOSSIM import *
import sys
from tinyos.tossim.TossimApp import *

EVENTS = 5000
n = NescApp("Unknown App", "app.xml")
vars = n.variables.variables()
t = Tossim(vars)
r = t.radio()

nodes = {}

t.addChannel("Boot", sys.stdout)
t.addChannel("Debug", sys.stdout)
t.addChannel("Messages", sys.stdout)

def run(args):
    if len(nodes) == 0:
        print("You need to load a topology first")
    else:
        if len(args) == 1:
            try:
                events = int(args[0])
                print("--------------------------")
                print("Running " + str(events) + " events")
                print("--------------------------")
                for i in range(events):
                    t.runNextEvent()
            except ValueError:
                print("ERROR: run argument must be a number!")
        else:
            print('You have to specify how many events you want to run')
            print("Example: 'run 3' will run 3 events")

def help(args):
    print("----------------------------")
    print("Available commands")
    print("----------------------------")
    print("load topology <filename> : Load a topology from a file")
    print("load noise <filename> : Load a noise model from a file")
    print("boot : Boot all nodes in the network")
    print("run <events> : run the next <events> in the node network")
    print("print topology : Prints the entire topology of the network")
    print("print state : Print the state for each node in the network")
    print("on <node id> Turn on node with id <node id>")
    print("off <node id> Turn off node with id <node id>")
    print("var <node id> <variable name> : Print the variable value of the node with <node id>")
    print("exit : Exit from the simulator")

def exit(args):
    print("Exiting...")
    sys.exit()

def load(args):
    if len(args) == 2:
        type = args[0]
        file_name = args[1]
        if type == 'topology':
            f = open(file_name, "r")
            nodes.clear()
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
        elif type == 'noise':
            if len(nodes) == 0:
                print("You need to load a topology first")
                print("Try: 'load topology filename'")
            else:
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
        else:
            print("Usage: load topology|noise filename")
    else:
        print("Usage: load topology|noise filename")

def boot(args):
    if len(nodes) == 0:
        print("You need to load a topology and a noise model first")
        print("Try load command")
        print("Type 'help' for more info")
    else:
        for i in nodes:
            time = (31 + t.ticksPerSecond() / 10) * i +  1
            print("Booting node " + str(i) + " in time " + str(time))
            t.getNode(i).bootAtTime(time)

def print_info(args):
    if len(args) == 0:
        print("Missing argument of print command")
    else:
        arg = args[0]
        if arg == 'topology':
            print("------------------------")
            print("Network topology")
            print("------------------------")
            for src in nodes:
                for dest in nodes:
                    if r.connected(src, dest):
                        print(str(src) + " --> " + str(dest))
        elif arg == 'state':
            print("------------------------")
            print("Nodes' states")
            print("------------------------")
            for i in nodes:
                node = t.getNode(i)
                if node.isOn():
                    state = 'ON'
                else:
                    state = 'OFF'
                print("Node " + str(i) + ": " + state)
        else:
            print("Wrong argument for print command")
            print("Usage: print topology")

def off(args):
    if len(args) == 1:
        try:
            id = int(args[0])
            node = t.getNode(id)
            node.turnOff()
            print("Node " + str(id) + " turned off")
        except ValueError:
            print("Argument of 'off' command must be the id of the node")
    else:
        print("Wrong argument for off command")
        print("Usage: off <node id>")

def on(args):
    if len(args) == 1:
        try:
            id = int(args[0])
            node = t.getNode(id)
            node.turnOn()
            print("Node " + str(id) + " turned on")
        except ValueError:
            print("Argument of 'on' command must be the id of the node")
    else:
        print("Wrong argument for on command")
        print("Usage: on <node id>")

def var(args):
    if len(args) == 2:
        try:
            id = int(args[0])
            var = args[1]
            node = t.getNode(id)
            v = node.getVariable(var)
            value = v.getData()
            print("Node " + str(id) + " variable: " + var + " value: " + str(value))
        except ValueError:
            print("Node id for 'var' command must be a number")
    else:
        print("Wrong arguments for var command")
        print("Usage: var <node id> <variable>")

options = {
    'help': help,
    'run': run,
    'exit': exit,
    'load': load,
    'boot': boot,
    'print': print_info,
    'off': off,
    'on': on,
    'var': var
}

def get_command(array):
    return array[0]

def get_args(array):
    return array[1:len(array)]

# Main loop
while True:
    print("> Type a command or just 'help'")
    user_input = raw_input()
    input_array = user_input.split()
    if(len(input_array) > 0):
        command = get_command(input_array)
        args = get_args(input_array)
        if options.has_key(command):
            options[command](args)
        else:
            print("You need to type a valid command")
            print("Type 'help' to see a list of all available commands")
    print("----------------------------------")
