#!/bin/bash
# this script displays system information

# TASK: This script produces a report. It does not communicate errors or deal with the user pressing ^C
#       Create the 4 functions described in the comments for
#         help display
#         error message display (2 of these)
#         temporary files cleanup to be used with interrupts
#       Create a trap command to attach your interrupt handling function to the signal that will be received if the user presses ^C while the script is running

# Start of section to be done for TASK
# This is where your changes will go for this TASK

# This function will send an error message to stderr

# Usage:
#   error-message ["some text to print to stderr"]
function error-message {
	#We can display this error message with $1 and direct it to stderr.
	#$? contains the exit status of the last job.
	echo "Error encountered: $1 [Exit status: $?]" >&2
}

# This function will send a message to stderr and exit with a failure status
# Usage
#   error-exit ["some text to print to stderr" [exit-status]]
function error-exit {
	#If there is no error message (User invoked help), don't do anything. $1 will be empty.
	if [ -z "$1" ]
	then
		#Do nothing.
		:
	else
		#We can display the error message with $1 and direct it to stderr like this.
		#$? contains the exit status of the last job.
		#echo "Error encountered: $1 [Exit status: $?]" >&2
		#We can also use this handy function above in order to report the error.
		error-message "$1"
	fi
	#We will exit no matter what happens.
	exit 1
}
#This function displays help information if the user asks for it on the command line or gives us a bad command line
function displayhelp {
	#We will echo all of the script options here.
	echo "This script produces a system report and has access to the following options:"
	echo
	echo "Script Options:"
	echo "-h | --help 	Display this help text."
	echo "--host	  	Display host information about this computer."
	echo "--domain    	Display domain of this computer."
	echo "--ipconfig  	Display ip configuration of this computer."
	echo "--os	  	Display the Operating System of this computer."
	echo "--cpu 	  	Display the CPU information of this computer."
	echo "--memory	Display the RAM information of this computer."
	echo "--disk	  	Display the disk information of this computer."
	echo "--printer	Display the printer information of this computer."
}

# This function will remove all the temp files created by the script
# The temp files are all named similarly, "/tmp/somethinginfo.$$"
# A trap command is used after the function definition to specify this function is to be run if we get a ^C while running
function cleanup {
	#If the user interrupts the job, we'll run this function and remove the report files.
	#The system generates: businfo, cpuinfo, memoryinfo, sysinfo, and sysreport.
	#There is probably an elegant way to do this since the .* is supposed to be the current PID ($$).
	rm -f /tmp/businfo.*
	rm -f /tmp/cpuinfo.*
	rm -f /tmp/memoryinfo.*
	rm -f /tmp/sysinfo.*
	#Let's exit because we are all done here.
	exit 0
}

#Here is a trap to catch SIGINT which should cover ctrl+c.
trap cleanup SIGINT SIGTERM

# End of section to be done for TASK
# Remainder of script does not require any modification, but may need to be examined in order to create the functions for TASK

# DO NOT MODIFY ANYTHING BELOW THIS LINE

#This function produces the network configuration for our report
function getipinfo {
  # reuse our netid.sh script from lab 4
  netid.sh
}

# process command line options
partialreport=
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      displayhelp
      error-exit
      ;;
    --host)
      hostnamewanted=true
      partialreport=true
      ;;
    --domain)
      domainnamewanted=true
      partialreport=true
      ;;
    --ipconfig)
      ipinfowanted=true
      partialreport=true
      ;;
    --os)
      osinfowanted=true
      partialreport=true
      ;;
    --cpu)
      cpuinfowanted=true
      partialreport=true
      ;;
    --memory)
      memoryinfowanted=true
      partialreport=true
      ;;
    --disk)
      diskinfowanted=true
      partialreport=true
      ;;
    --printer)
      printerinfowanted=true
      partialreport=true
      ;;
    *)
      error-exit "$1 is invalid"
      ;;
  esac
  shift
done

# gather data into temporary files to reduce time spent running lshw
sudo lshw -class system >/tmp/sysinfo.$$ 2>/dev/null
sudo lshw -class memory >/tmp/memoryinfo.$$ 2>/dev/null
sudo lshw -class bus >/tmp/businfo.$$ 2>/dev/null
sudo lshw -class cpu >/tmp/cpuinfo.$$ 2>/dev/null

# extract the specific data items into variables
systemproduct=`sed -n '/product:/s/ *product: //p' /tmp/sysinfo.$$`
systemwidth=`sed -n '/width:/s/ *width: //p' /tmp/sysinfo.$$`
systemmotherboard=`sed -n '/product:/s/ *product: //p' /tmp/businfo.$$|head -1`
systembiosvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/memoryinfo.$$|head -1`
systembiosversion=`sed -n '/version:/s/ *version: //p' /tmp/memoryinfo.$$|head -1`
systemcpuvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/cpuinfo.$$|head -1`
systemcpuproduct=`sed -n '/product:/s/ *product: //p' /tmp/cpuinfo.$$|head -1`
systemcpuspeed=`sed -n '/size:/s/ *size: //p' /tmp/cpuinfo.$$|head -1`
systemcpucores=`sed -n '/configuration:/s/ *configuration:.*cores=//p' /tmp/cpuinfo.$$|head -1`

# gather the remaining data needed
sysname=`hostname`
domainname=`hostname -d`
osname=`sed -n -e '/^NAME=/s/^NAME="\(.*\)"$/\1/p' /etc/os-release`
osversion=`sed -n -e '/^VERSION=/s/^VERSION="\(.*\)"$/\1/p' /etc/os-release`
memoryinfo=`sudo lshw -class memory|sed -e 1,/bank/d -e '/cache/,$d' |egrep 'size|description'|grep -v empty`
ipinfo=`getipinfo`
diskusage=`df -h -t ext4`
printerlist="`lpstat -e`
Default printer: `lpstat -d|cut -d : -f 2`"

# create output

[[ (! "$partialreport" || "$hostnamewanted") && "$sysname" ]] &&
  echo "Hostname:     $sysname" >/tmp/sysreport.$$
[[ (! "$partialreport" || "$domainnamewanted") && "$domainname" ]] &&
  echo "Domainname:   $domainname" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$osinfowanted") && "$osname" && "$osversion" ]] &&
  echo "OS:           $osname $osversion" >>/tmp/sysreport.$$
[[ ! "$partialreport" || "$cpuinfowanted" ]] &&
  echo "System:       $systemproduct ($systemwidth)
Motherboard:  $systemmotherboard
BIOS:         $systembiosvendor $systembiosversion
CPU:          $systemcpuproduct from $systemcpuvendor
CPU config:   $systemcpuspeed with $systemcpucores core(s) enabled" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$memoryinfowanted") && "$memoryinfo" ]] &&
  echo "RAM installed:
$memoryinfo" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$diskinfowanted") && "$diskusage" ]] &&
  echo "Disk Usage:
$diskusage" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$printerinfowanted") && "$printerlist" ]] &&
  echo "Printer(s):
$printerlist" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$ipinfowanted") && "$ipinfo" ]] &&
  echo "IP Configuration:" >>/tmp/sysreport.$$ &&
  echo "$ipinfo" >> /tmp/sysreport.$$

cat /tmp/sysreport.$$

# cleanup temporary files
cleanup
