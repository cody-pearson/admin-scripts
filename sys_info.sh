#!/bin/bash 
#==========================================================
# title           : sys_info.sh
# description     : RHEL 6 system info script.
# author          : Pearson
# date            : 2017 Feb 5 - 2017 Mar 3
# version         : 1.1
# usage           : bash sys_info.sh or ./sys_info.sh
# notes           : Need root or sudo permissions to run.
# TODO            : 1) More precise reporting
#                 : 2) Add more "meaningful" metrics
#==========================================================

#Variables
hn=$(hostname -a)
today=$(date +%F)
info_log=/path/to/"$hn"_sys_info."$today"

## Run as root
if [[ "$UID" -ne "0" ]]; then
  echo "You need to be root to run this script!!"
  exit
fi

## Check for sysinfo file
if [[ -f "$info_log" ]]; then
  echo "$hn appears to already have a system info file"
  read -p "Would you like to delete it? [Y]/[N]  "  dfile
    if [[ "$dfile" == [Yy][Ee][Ss] ]] || [[ "$dfile" == [Yy] ]]; then
      echo "Deleting $info_log"
      rm -f $info_log
      echo "Creating a new info file for $hn  "
    elif [[ "$dfile" == [Nn][Oo] ]] || [[ "$dfile" == [Nn] ]]; then
      echo "You may want to copy $info_log"
      echo "to another location if you want to keep this file for"
      echo "archiving purposes and then rerun this script..."
      exit
    else
      echo "That was not a valid answer...."
      exit
    fi
else
  touch $info_log 2> /dev/null
    if [[ "$?" -ne "0" ]]; then
      echo "***ERROR*** There was an issue creating the sys_info file"
      exit
    else
      echo "The sys_info file is located here:  $info_log   "
    fi
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

echo ""
echo "Your sys_info file is located at "$info_log"  "

