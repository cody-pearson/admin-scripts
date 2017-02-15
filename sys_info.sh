#!/bin/bash 
#==========================================================
#title           :sys_info.sh
#description     :RHEL 6 system info script.
#author          :Pearson
#date            :2017 Feb 5
#version         :1.0    
#usage           :bash sys_info.sh or ./sys_info.sh
#notes           :Need root or sudo permissions to run.
#==========================================================

#Variables
hn=$(hostname -a)
inf_log=/path/to/"$hn"_sys_info

## Check to see if root is running
if [[ "$USER" != "root" ]]; then
  echo "You need to be root to run this script!!"
  exit
fi

## Check for sysinfo file
if [[ -f "$info_log" ]]; then
  echo ""$hn" appears to already have a system info file"
  read -p "Would you like to delete it? [Y]/[N]  "  dfile
    if [[ "$dfile" == [Yy][Ee][Ss] ]] || [[ "$dfile" == [Yy] ]]; then
      echo "Deleting "$info_file"
      rm -f "$info_log"
      echo "Creating a new info file for "$hn"  "
    else
      echo "You may want to copy "$info_log"
      echo "to another location if you want to keep this file for"
      echo "archiving purposes and then rerun this script..."
      exit
    fi
else
  touch "$info_log"
fi

## Hostname
echo "Getting Hostname"
echo -n "Hostname:  " > "$info_file"
hostname -a >> "$info_log"

## Hardware Serial Number
echo "Getting Machine Serial Number"
echo -n "Machine Product and Serial Number:  " >> "$info_log"
dmidecode -t 1 | grep -e 'Manufacturer' -e 'Product Name' -e 'Serial Number' | head -n 3 >> "$info_log"

## Hard Drive Serial Number
echo "Reading Hard Drive Serial Number"
echo -n "Hard Drive Serial Number:  " >> "$info_log"
hdparm -i /dev/sda | grep -i SerialNo=* >> "$info_log"

## MAC Addresses
echo "Getting MAC Address"
echo -n "MAC Addresses:  " >> "$info_log"
ifconfig -a | grep -i HWaddr >> "$info_log"

echo "Your system info file is located at "$info_log"  "


## TODO:
### script isn't as precise as I want... will continue to refine searches  //CP
### Obviously more metrics can be found... Depends on requested resource  //CP
