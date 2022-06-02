#!/bin/bash
#Check for root.
if [ "$EUID" -ne 0 ]
then
	echo "Please run this script as the root user."
	exit
fi

#Check if LXD is installed. If it isn't, install it and set it up automatically.
if [ ! -d /usr/sbin/lxd ]
then
	echo "Lxd is not installed. Installing lxd..."
	#Install lxd and run initalization...
	apt -y install lxd-installer > /dev/null
	echo "Initializing lxd with auto..."
	lxd init --auto
	echo "Lxd is done."
fi

#We should be able to set up the Ubuntu server.
lxc launch ubuntu:22.04 COMP2101-S22

#Once the server launches, we can fetch the IP address from the lxc list and add it to the hosts file.
#Sometimes this command will not pick up the IP address and will instead pick up the "|" in the output, so I'll have it wait for the container to launch.
sleep 8
lxc list | grep "COMP2101-S22" | awk '{print $6 " " $2}' >> /etc/hosts

#We can send commands to the VM in order to update the server and have apache2 installed.
echo "Updating container..."
lxc exec COMP2101-S22 -- apt -y update > /dev/null
echo "Installing Apache..."
lxc exec COMP2101-S22 -- apt-get -y install apache2 > /dev/null

#Check is curl is installed - it isn't by default!
if [ ! -d /usr/bin/curl ]
then
	echo "Curl is not installed, installing Curl..."
	apt -y install curl > /dev/null
fi

#Once Apache2 is installed, we can test if the test website is active.
if curl --head --silent --fail COMP2101-S22 > /dev/null;
then
	echo "The page exists!"
else
	echo "The page is not reachable."
fi
