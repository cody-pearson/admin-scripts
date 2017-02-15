#!/bin/bash 
#==========================================================
#title           :join_ad.sh
#description     :copy config files and join AD domain.
#author          :Pearson
#date            :2017 Feb 5
#version         :1.0    
#usage           :bash join_ad.sh or ./join_ad.sh
#notes           :script copies config file from share dir.
#TODO            : 1) better error checking
                   2) better service statuses
#==========================================================

## Variables
backupdir=/path/to/backup/dir/
configdir=/path/to/config/files

## Run as root
if [[ ! ""$UID" -eq 0 ]]; then
  echo "This script must be ran as root"
  echo "Try using 'sudo "$0"' next time."
  exit
else
  echo "You are running as root...Good"
fi

## Check for backup directory
if [[ -d "$backupdir" ]]; then
  echo "You already have a backup directory:  "$backupdir"  "
  echo "Current system config files will be moved there  "
else
  echo "Creating the backup directory"
  mkdir -p "$backupdir" > /dev/null
    if [[ "$?" -ne 0 ]]; then
      echo "There was an error creating the backup directory"
      echo "Make sure you have permission to create "$backupdir" "
      echo "and run the script again"
    fi
fi

## Move system files to backup directory
echo "Moving system config files to "$backupdir"  "
mv /etc/krb5.conf "$backupdir"
mv /etc/samba/smb.conf "$backupdir"
mv /etc/pam.d/system-auth-ac "$backupdir"
mv /etc/pam.d/password-auth-ac "$backupdir"
mv /etc/ntp.conf "$backupdir"
mv /etc/ntp/step-tickers "$backupdir"
mv /etc/resolv.conf "$backupdir"
mv /etc/nsswitch.conf "$backupdir"
mv /etc/gdm/custom.conf "$backupdir"
echo "Finished moving files to "$backupdir" "

## Move config files to local machine
echo "Moving config files to the local machine"
cp -p "$stigdir"/krb5.conf /etc/
cp -p "$stigdir"/smb.conf /etc/samba/
cp -p "$stigdir"/system-auth-ac /etc/pam.d/
cp -p "$stigdir"/password-auth-ac /etc/pam.d/
cp -p "$stigdir"/ntp.conf /etc/
cp -p "$stigdir"/step-tickers /etc/ntp
cp -p "$stigdir"/resolv.conf /etc/
cp -p "$stigdir"/nsswitch.conf /etc/
cp -p "$stigdir"/custom.conf /etc/gdm
echo "Finished moving config files to local system "

## Fix permissions on moved files
echo "Changing permissions on files that were copied"
chmod 644 /etc/nsswitch.conf
chmod 744 /etc/pam.d/system-auth-ac
chmod 644 /etc/pam.d/password-auth-ac
chmod 644 /etc/postfix/main.cf
echo "Finished changing permissions on files "

## Restart / Auto-Start services
echo "Checking NTP service "
service ntpd status > /dev/null
  if [[ "$?" -eq 0 ]]; then
    echo "NTP is running... Restarting now "
    service ntpd restart > /dev/null
  else [[ "$?" -gt 0 ]]; then
    echo "NTP is stopped... Starting now "
    service ntpd start > /dev/null
  fi

chkconfig --list ntpd | grep "3:off" > /dev/null
  if [[ "$?" -eq 0 ]]; then
    echo "NTP is set to start at boot... Good "
  else [[ "$?" -ne 0 ]]; then
    echo "NTP is not set to start at boot... Correcting now"    
    chkconfig ntpd on
  fi
  
echo "Checking winbind service"
service winbind status > /dev/null
  if [[ "$?" -eq 0 ]]; then
    echo "Winbind is running... Restarting now "
    service winbind restart > /dev/null
  else [[ "$?" -gt 0 ]]; then
    echo "winbind is stopped... Starting now "
    service winbind start > /dev/null
  fi
  
chkconfig --list winbind | grep "3:off" > /dev/null
  if [[ "$?" -eq 0 ]]; then
    echo "Winbind is set to start at boot... Good "
  else [[ "$?" -ne 0 ]]; then
    echo "Winbind is not set to start at boot... Correcting now"
    chkconfig winbind on
  fi
  
## Prompt for Admin AD account -- Join AD Domain
read -p "Please enter your Administrator account username:  "  admin
  net ads join -U "$admin" osName=RHEL osVer=6.8
 
 ## Reboot for changes to take effect
 read -p "Please press <Enter> to restart the system. "
 init 6
