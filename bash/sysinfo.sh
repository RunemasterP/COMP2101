#!/bin/bash
#Use the hostname variable to fetch the hostname...
#echo 'Hostname:' $HOSTNAME
#We can use the domain name command to get that. -n on echo will keep it on one line.
#echo -n 'Domain Name: '
#domainname
#We can fetch the OS information from this file and grep it to get the right version.
#echo 'Operating System and Version:'
#cat /etc/os-release | grep "PRETTY_NAME"
#IP Addresses that do not begin with 127. You can use hostname for this.
#echo 'IP Addresses: '
#hostname -I
#The root file system. You can use '/' on df to fetch that.
#echo 'The Root File System: '
#df -h /

#Version 2.0 below!
#FQDN is easy enough to fetch...
hostname=$(hostname -f)
#Here we'll grab the "Pretty name", cut the quotes, and extract the fancy OS name.
osInfo=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d '"' -f 2)
#Fetch the ipv4 addresses, capture the addresses and remove the loopback, drop the mask, and select the address.
ipAddress=$(ip -4 addr | grep 'inet' | grep -v 127.0.0.1 | cut -d "/" -f1 | awk '{print $2}')
#Fetch the total space used, select the line we want, and use awk to cut out the field we require.
freeSpace=$(df / -h | grep sda | awk '{print $4}')
echo 'Report for: '$HOSTNAME
echo "-----------------------------------------------------------"
echo "FQDN: $hostname"
echo "Operating System and Version: $osInfo"
echo "IP Address is: $ipAddress"
echo "Free space available on this machine: $freeSpace"
echo "-----------------------------------------------------------"

