# fire-detection
A sensor network for fire detection.

This is a project of a network of nodes to detect a fire in a forest.

## Requirements
### Install TinyOS 2.1.2 natively

* [TinyOS 2.1.2](https://github.com/tinyos/tinyos-main): This can be a little tricky to install. It's easier on Ubuntu. But anyway, you have to pollute your OS with a lot of trash. It gets worst if you do not use Ubuntu. For instance, if you use Mac OS or even worst, Windows, you should definitely forget this option and go for Vagrant way

### Using Vagrant (Recommended)

* [Virtualbox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

## Compiling for TOSSIM using Vagrant
If you are using vagrant, there is a Vagrantfile with everything that is needed to work with TinyOs.

So, you only need to boot it:

```
vagrant up
```

There is a Makefile in the project's root which will ssh to vagrant environment and run the command to build it for [TOSSIM](http://tinyos.stanford.edu/tinyos-wiki/index.php/TOSSIM), which is a very nice simulator for TinyOS and will allow you to test the project in a really easy way. To do so, you just have to run make command:

```
make
```

### Without Vagrant
If you choose to not use vagrant and have everything installed on your machine (can be an interesting option if you want to develop for TinyOS using a [Raspberry Pi](https://www.raspberrypi.org/) ), you have to go to src directory:

```
cd src/
```

And run make

```
make micaz sim
```

## Run the simulator
There will be a simulator written in python to simulate different events in the node network.

TODO: Implement the simulator and describe it here
