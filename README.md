# fire-detection
A sensor network for fire detection.

This is a project of a network of nodes to detect a fire in a forest.

## Requirements
### Install TinyOS 2.1.2 natively

* [TinyOS 2.1.2](https://github.com/tinyos/tinyos-main): This can be a little tricky to install. It's easier on Ubuntu. But anyway, you have to pollute your OS with a lot of trash. It gets worst if you do not use Ubuntu. For instance, if you use Mac OS or even worst, Windows, you should definitely forget this option and go for Vagrant way

### Using Vagrant (Recommended)

* [Virtualbox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

## Compile

### With Vagrant
If you choose to use vagrant, there is a Vagrantfile with everything that is needed to work with TinyOs.

So, you only need to boot it:

```
vagrant up
```

There is a Makefile in the project's root which will ssh to vagrant environment and run the commands inside the virtual machine without the need of you ssh to the VM first and issue each command.

To build it for [TOSSIM](http://tinyos.stanford.edu/tinyos-wiki/index.php/TOSSIM), just run:

```
make tossim
```

To build for micaz motes you can run:

```
make micaz
```

After you are done, you can shutdown the vagrant VM.

```
vagrant halt
```

### Without Vagrant
If you choose to not use vagrant and have everything installed on your machine (can be an interesting option if you want to develop for TinyOS using a [Raspberry Pi](https://www.raspberrypi.org/) ), you have to go to src directory:

```
cd src/
```

And run the make targets available in the Makefile there.

To build it for TOSSIM just run:

```
make micaz sim
```

To build for micaz motes run:

```
make micaz
```

## Simulator
There is a simulator, written in python, that allow you to simulate any kind of network and a lot of different situations

### Run using Vagrant
If you are using vagrant you can use the Makefile in the project's root.

```
make run
```

### Run without using Vagrant
If you were brave enough to have everything installed on your machine you have to go to src directory

```
cd src/
```

and run the simulator

```
python simulator.py
```

### Features
After you start the simulator a command line application will show up and will be waiting for your commands.

To know all available commands you can just type:

```
help
```
and press Enter.

To exit from the simulator just type:

```
exit
```
and press Enter

##### Load a network topology from a file

```
load topology <filename>
```

This file is just a text file where each line is in the format
```
<src> <dest> <gain>
```
which means that node <src> can send messages to node <dest> with gain <gain>

You have topology files examples in topologies directory

##### Load a noise model from a file

```
load noise <filename>
```

File with name filename is a text file where each line is the value of the signal's strength. You have an example of a "dummy" noise model in noise directory.

##### Boot all nodes in the network

```
boot
```

All nodes will become in state ON

##### Print the network topology

```
print topology
```

##### Print the state of each node

```
print state
```

For each node, the state will be ON/OFF

##### Print the routing node for each sensor node

```
print routing
```

For each sensor node, it prints which routing node it is using to send its messages

##### Print rank of each routing node

```
print rank
```

##### Print content of the server's log file

```
print server
```

##### Run a number of events

```
run <events>
```

The simulator will run events in the network. The output depends on "dbg" statements in the code

##### Turn on one node

```
on <node>
```

It turns on the node with the given id

##### Turn off one node

```
off <node>
```

It turns off the node with the given id. This is useful to test the fault-tolerance of the sensor network

##### Get a variable's value of a given node

```
var <node> <variable>
```

##### Enable a debug channel

```
debug enable <channel>
```

Depends on "dbg" statements in the code

##### Disable a debug channel

```
debug disable <channel>
```

Depends on "dbg" statements in the code

##### See a list of all available debug channels

```
debug
```

##### Execute a list of commands from a file

```
script <filename>
```

The file is just a text file where each line is one of the available commands described so far.

There are examples of script files in scripts directory.
If you put your script files in that directory the filename you provide does not need to include the complete path. By default, when the file is not found it will try to find it in scripts directory.

For instance, to execute the script with name "script.txt" inside scripts directory just issue the command:

```
script script.txt
```

##### Stop the simulation and continue when the user presses Enter

```
stop
```

This command is useful in script files when you want to break the simulation in multiple steps instead of getting all the output at once.
