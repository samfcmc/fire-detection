# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT
read -d '' APT_SNIPPET <<EOF
deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse
EOF
echo "$APT_SNIPPET" | cat - /etc/apt/sources.list > /tmp/out && sudo mv /tmp/out /etc/apt/sources.list

TOSPROD="/etc/apt/sources.list.d/tinyprod-debian.list"
echo "deb http://tinyos.stanford.edu/tinyos/dists/ubuntu natty main" | sudo tee -a $TOSPROD

sudo apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" \
                                       -o Dpkg::Options::="--force-confold" \
                                       -qy dist-upgrade
sudo apt-get install tinyos-2.1.2 tinyos-tools msp430-46 g++ python-dev nesc -qy --force-yes

read -d '' PROFILE_SNIPPET <<"EOF"
export TOSROOT=/opt/tinyos-2.1.2
export TOSDIR=$TOSROOT/tos
export CLASSPATH=$CLASSPATH:$TOSROOT/support/sdk/java
export MAKERULES=$TOSROOT/support/make/Makerules
export PATH=/opt/msp430/bin:$PATH
source /opt/tinyos-2.1.2/tinyos.sh
EOF
echo "$PROFILE_SNIPPET" | tee -a /home/vagrant/.profile

sudo chown vagrant:vagrant  -R /opt/tinyos-2.1.2/
sudo gpasswd -a vagrant dialout
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise32"
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  config.ssh.forward_agent = true
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    # vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision "shell", inline: $script
end
