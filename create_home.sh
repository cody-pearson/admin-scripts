#!/bin/bash 
#==========================================================
#title           :create_home.sh
#description     :creates home dir and setup user env
#author          :Pearson
#date            :2017 Feb 5
#version         :1.0    
#usage           :bash create_home.sh or ./create_home.sh
#notes           :create/setup single user home dir
#Todo            : 1) more than 1 user at a time
                   2) logging
#==========================================================

## Varialbles
hn=$(hostname -a)
launch_dir=/path/to/launchers

## Function
setup_launchers () {
  echo "Setting up launchers for "$user"  "
  cp "$launch_dir"/.cshrc "$user_home"/
  cp "$launch_dir"/.Xdefaults "$user_home"/
  cp "$launch_dir"/launchers.zip "$user_home"/
    if [[ "$?" -ne 0 ]]; then
      echo "***ERROR*** Failed to copy files to "$user_home"
      exit
    fi
  unzip "$user_home"/launchers.zip > /dev/null
  chown -R "$user" "$user_home"
 }
 
## Check for DIR Server
if [[ "$hn" != dirsvr ]]; then
  echo "***ERROR*** You are not on DIRSVR"
  echo "***ERROR*** ssh to DIRSVR and rerun "$0"  "
  exit
else
  echo "You're on "$hn"
fi
 
## Check for root
if [[ "$UID" != 0 ]]; then
  echo "***ERROR*** You are running the script as "$USER"  "
  echo "***ERROR*** su to root or use sudo and then rerun the script"
  exit
else
  echo "You're running the script as "$USER"  "
fi
 
## Prompt for username to create $user home directory
read -p "Enter the username of the user you want to setup    " name
  for user in "$name"; do
user_home=/home/"$user"
    echo ""
## Search AD for $user
    echo "Searching for Active Directory Account for "$user"  "
    wbinfo -u | grep "$user" > /dev/null
      if [[ "$?" -ne 0 ]]; then
        echo "***ERROR*** There is no user in AD with that name"
        echo "***ERROR*** Please create the user in AD before running this script"
        exit
      else
        echo "User has an account in AD... Good
      fi
    
## Search for home directory
    echo "Check if "$user" has a home directory already...  "
    ls /home/ | grep -x "$user" > /dev/null
      if [[ "$?" -ne 0 ]]; then
        echo "Creating home directory for "$user"  "
        su -c whoami "$user" > /dev/null
      ls /home/ | grep -x "$user" > /dev/null
        if [[ "$?" -ne 0 ]]; then
          echo "***ERROR*** Failed to create home directory for "$user"  "
          exit
        else
          echo "Copying launchers to "$user_home"
          setup_launchers
        fi
      else
        echo "***INFO*** "$user" already has a home directory  "
        echo ""
        read -p "Did you want to re-copy LAUNCHERS for "$user"?  "   ans1
          if [[ "$ans1 == [Yy][Ee][Ss] ]] || [[ "$ans1" == [Yy] ]]; then
            setup_launchers
          else
            echo "***END*** Finished running "$0"  "
            exit
          fi
      fi
  done
  
echo "***END*** Finished running "$0"  "
