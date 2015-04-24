from TOSSIM import *
import sys

EVENTS = 5000

t = Tossim([])
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

options = {
    'help': help,
    'run': run,
    'exit': exit,
    'load': load,
    'boot': boot
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
