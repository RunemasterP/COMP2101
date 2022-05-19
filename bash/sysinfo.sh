#!/bin/bash
#Use the hostname variable to fetch the hostname...
echo 'Hostname:' $HOSTNAME
#We can use the domain name command to get that. -n on echo will keep it on one line.
echo -n 'Domain Name: '
domainname
#We can fetch the OS information from this file and grep it to get the right version.
echo 'Operating System and Version:'
cat /etc/os-release | grep "PRETTY_NAME"
#IP Addresses that do not begin with 127. You can use hostname for this.
echo 'IP Addresses: '
hostname -I
#The root file system. You can use '/' on df to fetch that.
echo 'The Root File System: '
df -h /
