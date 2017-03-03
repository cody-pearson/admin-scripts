#!/bin/bash  
#========================================================== 
# title           :mod_fstab.sh 
# description     :modify fstab 
# author          :Pearson 
# date            :2017 Mar 3 
# version         :1.1
# usage           :bash mod_fstab.sh or ./mod_fstab.sh 
# notes           :modifies fstab ....  backup file created 
# todo            :1) 
#  
# example         :for comp in $(cat machines.txt); do  
#                  ssh -t "$comp" 'bash \
#                  /path/to/script/mod_fstab.sh; bash -l' 
#                  done
#==========================================================

echo "Checking fstab on "$HOSTNAME" for incorrect nfs data"

## Run as root
if [[ "$UID" -ne "0" ]]; then
  echo "You need to be root or use sudo for this script"
  quit
fi

## Backup local fstab
echo "Creating backup of fstab (file will be named fstab$(date +%Y%m$d_%H%M%S)  "
echo "***INFO*** use backup fstab file in case something breaks and you can not boot "
  cp /etc/fstab /etc/fstab.$(date +%Y%m%d_%H%M%S)
    if [[ ! -f /etc/fstab.$(date +%Y%m%d_%H%M%S); then
      echo "Failed to create back up fstab file"
      quit
    fi

## Commenting old entries and adding entries to fstab
  sed -ci 's/^nfssvr1/#nfssvr1/g' /etc/fstab
  grep nfssvr1 /etc/fstab > /etc/fstab.bk
  sed -ci 's/#nfssvr1/nfssvr/g' /etc/fstab.bk
  cat /etc/fstab.bk >> /etc/fstab
  rm -f /etc/fstab.bk

## Home dir creation
  if [[ ! -d /home/users ]]; then
    mkdir -p /home/users
  fi

## Correcting fstab for users home dir
  grep nfssvr:/home/users /etc/fstab > /dev/null
    if [[ "$?" -ne 0 ]]; then
      echo "***WARN*** The users dir is not correct
      echo "Correcting now...."
      sed -ci 's/home/home\/users/g' /etc/fstab
    fi

## Commenting useless entries in fstab 
  sed -ci 's/nfssvr:\/test/#nfssvr:\/test/' /etc/fstab
  sed -ci 's/nfssvr:\/share/#nfssvr:\/share/' /etc/fstab

echo ""
echo "***INFO*** Remember to remount shares or reboot the machine to force remounts"
