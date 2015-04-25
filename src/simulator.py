from TOSSIM import *
import sys
from tinyos.tossim.TossimApp import *

EVENTS = 5000
n = NescApp("Unknown App", "app.xml")
vars = n.variables.variables()
t = Tossim(vars)
r = t.radio()

nodes = {}
last_noise_filename = None
debug_channels = {
    'Boot': True,
    'Debug': True,
    'Messages': False,
    'Start': False
}

t.addChannel("Boot", sys.stdout)
t.addChannel("Debug", sys.stdout)

def load_noise(filename):
    global last_noise_filename
    last_noise_filename = filename
    noise = open(filename, "r")
    for line in noise:
      str1 = line.strip()
      if str1:
        val = int(str1)
        for i in nodes:
            t.getNode(i).addNoiseTraceReading(val)
    for i in nodes:
      t.getNode(i).createNoiseModel()

def boot_node(nodeid):
    time = (31 + t.ticksPerSecond() / 10) * nodeid +  1
    print("Booting node " + str(nodeid) + " in time " + str(time))
    t.getNode(nodeid).bootAtTime(time)


"""
Commands
"""
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
    print("print routing : For each sensor node prints the routing node that it is connected to")
    print("on <node id> Turn on node with id <node id>")
    print("off <node id> Turn off node with id <node id>")
    print("var <node id> <variable name> : Print the variable value of the node with <node id>")
    print("add <src_id> <dest_id> <gain> Add a link in the network topology from node <src_id> to <dest_id> with gain <gain>")
    print("script <file> : Loads commands from a file with name <file>")
    print("debug : Print all available debug channels")
    print("debug enable <Channel> : Enables the debug channel <Channel>")
    print("debug disable <Channel> : Disables the debug channel <Channel>")
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
                load_noise(file_name)
                print("Noise model from " + file_name + " loaded")
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
            boot_node(i)

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
        elif arg == 'routing':
            print("------------------------")
            print(" Sensor node -> Routing node")
            print("------------------------")
            for i in nodes:
                if i > 99:
                    m = t.getNode(i)
                    var = m.getVariable('NodeP.routeNodeAddr')
                    value = var.getData()
                    print(str(i) + " --> " + str(value))
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

def add(args):
    if len(args) == 3:
        try:
            src_id = int(args[0])
            dest_id = int(args[1])
            gain = int(args[2])
            r.add(src_id, dest_id, gain)
            m1 = t.getNode(src_id)
            m2 = t.getNode(dest_id)
            if not nodes.has_key(src_id):
                nodes[src_id] = m1
                print("New node in the network. id: " + str(src_id))
                boot_node(src_id)
            if not nodes.has_key(dest_id):
                nodes[dest_id] = m1
                print("New node in the network. id: " + str(dest_id))
                boot_node(dest_id)
            load_noise(last_noise_filename)
        except ValueError:
            print("Arguments of 'add' command should be numbers")
    elif len(nodes) == 0:
        print("You need to load a topology first")
        print("Try: load topology <filename>")
    else:
        print("Wrong usage of command add")
        print("Usage: add <src_id> <dest_id> <gain>")

def script(args):
    if len(args) == 0:
        print("Command script takes one argument which is the script file name")
    else:
        filename = args[0]
        file = open(filename, "r")
        for line in file:
            process_input(line)
        file.close()

def print_channels():
    global debug_channels
    print("Available channels")
    for channel in debug_channels:
        state = debug_channels[channel]
        if state:
            state_str = 'ENABLED'
        else:
            state_str = 'DISABLED'
        print(str(channel) + ": " + state_str)

def debug(args):
    if len(args) == 2:
        global debug_channels
        action = args[0]
        channel = args[1]
        if debug_channels.has_key(channel):
            if action == 'enable':
                t.addChannel(channel, sys.stdout)
                debug_channels[channel] = True
            elif action == 'disable':
                t.removeChannel(channel, sys.stdout)
                debug_channels[channel] = False
            else:
                print("Wrong argument for command debug")
        else:
            print("Channel " + str(channel) + " is not available")
            print_channels()
    else:
        print("Command debug takes 2 arguments")
        print("Usage: debug enable|disable <Channel>")
        print_channels()

options = {
    'help': help,
    'run': run,
    'exit': exit,
    'load': load,
    'boot': boot,
    'print': print_info,
    'off': off,
    'on': on,
    'var': var,
    'add': add,
    'script': script,
    'debug': debug
}

def get_command(array):
    return array[0]

def get_args(array):
    return array[1:len(array)]

def process_input(user_input):
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

if len(sys.argv) >= 2:
    script_file = open(sys.argv[1], "r")
    for line in script_file:
        process_input(line)

print("-------------------------------------------")
print(" Fire Detection Sensor Network Simulator")
print("-------------------------------------------")

# Main loop
while True:
    print("> Type a command or just 'help'")
    user_input = raw_input()
    process_input(user_input)
