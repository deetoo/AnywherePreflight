#!/bin/bash
clear
MyOS=`cat /etc/os-release |grep ^ID=|cut -d\" -f2`
MyVERSION=`cat /etc/os-release |grep ^VERSION_ID=|cut -d\" -f2`
LOGFILE="/tmp/preflight.txt"
MyDATE=`date +%D`
MySERVER=`hostname`

# create the logfile with seom generic info.
echo -e "Armor Anywhere Preflight Test v1.00\n"

echo "[begin]"		>$LOGFILE
echo "Created: $MyDATE" >>$LOGFILE
echo "Server: $MySERVER" >>$LOGFILE
echo -e "OS: $MyOS $MyVERSION \n" >>$LOGFILE

# verify outbound connectivity to all Armor resources.
# update this to be more chatty on any failures. -DD
function NetCheck()
{
ip=( "146.88.106.210 -p 443"
     "146.88.106.197 -p 4119"
     "146.88.106.197 -p 4120"
     "146.88.106.197 -p 4122"
     "146.88.106.196 -p 515"
     "146.88.106.200 -p 8443"
     "146.88.106.216 -p 443"
     "cloud.tenable.com -p 443" )
 
  for i in "${ip[@]}"
     do
	if nmap -P0 $i > /dev/null 2>&1
      then
        NCHECK=1
      else
	# any failed test = complete failure.
	echo "Network Test Failed!"
	echo "Please check $LOGFILE"
	echo "Network Test: Failed!" >>$LOGFILE
	exit 1
      fi
  done
	echo -e "Network Test: Passed\n"
	echo "Network Test: Passed" >>$LOGFILE
}

if [ $MyOS = "centos" ] || [ $myOS = "rhel" ]
	then
		echo "CentOS or RedHat detected:"
		if [ $MyVERSION -ge 6 ]
			then
				echo -e "Supported version.\n"
				if [ -f /usr/bin/nmap ]
					then
						echo "Checking outbound connectivity."
						NetCheck
					else
						echo "Please install nmap, and then execute this script. Exiting!"
						exit
				fi
		else
				echo "OS Error: Unsupported OS version" >>$LOGFILE
				echo "Unsupported version of this OS. Exiting!"
				exit
		fi
fi

if [ $MyOS == "ubuntu" ]
	then
		echo "Ubuntu detected:"
		if [ $MyVERSION -ge 12 ]
			then
				echo -e "Supported version.\n"
				if [ -f /usr/bin/nmap ]
					then
						echo "Outbound Connectivity Check:"
							NetCheck
					else
						echo "Please install nmap, and then execute this script. Exiting!"
						exit
				fi
		else
				echo "OS Error: Unsupported OS version" >>$LOGFILE
				echo "Unsupported version of this OS. Exiting!"
				exit
		fi
fi


# verify 64bit OS
echo "Architecture Check:"

if [ `lscpu |grep Architecture |awk '{print $2}'` != 'x86_64' ]
	then
		echo "32-bit operating systems are not supported."
		echo "Architecture Error: 32-bit OS detected." >>$LOGFILE
	else
		echo -e "64-bit OS detected.\n"
		echo "Architecture Check: Passed" >>$LOGFILE
fi

# right now this just dumps the free space to the logfile.
# it does NOT verify enough space exists.
echo "Disk Space Check:"
MyFREE=`df -kh /opt|tail -1|awk '{print $4}'`
echo -e "Available space: $MyFREE - 3GB is needed.\n"
echo "Disk Space: $MyFREE" >>$LOGFILE

echo "[end]" >>$LOGFILE
echo "Script completed, please check $LOGFILE for results."
