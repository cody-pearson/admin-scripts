#!/bin/bash 
#==========================================================
#title           :app_logs.sh
#description     :Searches through $app logs for errors.
#author          :Pearson
#date            :2017 Feb 5
#version         :1.0    
#usage           :bash app_logs.sh or ./app_logs.sh
#notes           :Specific hardcoded paths based on $app.
#==========================================================

#Variables
logdir=/path/to/app/logs
scriptdir=/path/to/script

## Checking that $appuser is running the script
if [[ "$USER" != appuser ]]; then
  echo "You need to be appuser to run this script   "
  exit
fi

## Checking that script is running on correct server
if [[ "$HOSTNAME" != appserver[1234] ]]; then
  echo "You must be on an APP SERVER to run this script  "
  exit
fi

## Loop through configured $app logs
while true; do
  echo "
         Which APP log would you like to search:
        
         1. Informational
         2. Warning
         3. Error
         4. Critical
         5. Debug
         0. Quit
        
         Please select one of the above (0-5): "
        
 read choice
  if [[ "$choice" == "1" ]]; then
    echo ""
    echo "Here's the last 5 Info Logs from the last 24-hrs:  "
    find "$logdir" / --mmin -1440 -name "log.info.*" | cut f6 -d"/" | sort -n | tail -n 5
    echo ""
    echo "Which Info Logs do you want to see? (Newest at Bottom) "
    read info
      if [[ "$info" =~ log.info.* ]]; then
        grep 'ERROR' "$logdir"/"$info" | cut -f2-9 -d' ' | sort -k3,4 -k9 -u
        echo ""
      else
        echo ""
        echo "******************************"
        echo "That's not an Info Log file!!!"
        echo "******************************"
      fi
    echo ""
    echo "Do you want to look at more logs: [Y]es/[N]o"
    read answer
      if [[ "$answer" == [Nn][Oo] ]] || [[ "$answer" == [Nn] ]]; then
        exit
      elif [[ "$answer" == [Yy][Ee][Ss] ]] || [[ "$answer" == [Yy] ]]; then
        continue
      fi
  fi
  
  if [[ "$choice" == "2" ]]; then
    echo ""
    echo "Here's the last 5 Warning Logs from the last 24-hrs:  "
    find "$logdir" / --mmin -1440 -name "log.warn.*" | cut f6 -d"/" | sort -n | tail -n 5
    echo ""
    echo "Which Warning Logs do you want to see? (Newest at Bottom) "
    read warn
      if [[ "$warn" =~ log.warn.* ]]; then
        grep 'ERROR' "$logdir"/"$warn" | cut -f2-10 -d' ' | sort -k3,3 -k4,4 -k10 -u
        echo ""
      else
        echo ""
        echo "******************************"
        echo "That's not a Warning Log file!!!"
        echo "******************************"
      fi
    echo ""
    echo "Do you want to look at more logs: [Y]es/[N]o"
    read answer
      if [[ "$answer" == [Nn][Oo] ]] || [[ "$answer" == [Nn] ]]; then
        exit
      elif [[ "$answer" == [Yy][Ee][Ss] ]] || [[ "$answer" == [Yy] ]]; then
        continue
      fi
  fi
  
  if [[ "$choice" == "3" ]]; then
    echo ""
    echo "Here's the last 5 Error Logs from the last 24-hrs:  "
    find "$logdir" / --mmin -1440 -name "log.err.*" | cut f6 -d"/" | sort -n | tail -n 5
    echo ""
    echo "Which Error Logs do you want to see? (Newest at Bottom) "
    read error      
      if [[ "$error" =~ log.err.* ]]; then
        grep 'ERROR' "$logdir"/"$error" | cut -f2-10 -d' ' | sort -k3,4 -k5,5 -k10 -u
        echo ""
      else
        echo ""
        echo "******************************"
        echo "That's not an Error Log file!!!"
        echo "******************************"
      fi
    echo ""
    echo "Do you want to look at more logs: [Y]es/[N]o"
    read answer
      if [[ "$answer" == [Nn][Oo] ]] || [[ "$answer" == [Nn] ]]; then
        exit
      elif [[ "$answer" == [Yy][Ee][Ss] ]] || [[ "$answer" == [Yy] ]]; then
        continue
      fi
  fi
  
  if [[ "$choice" == "4" ]]; then
    echo ""
    echo "Here's the last 5 Critical Logs from the last 24-hrs:  "
    find "$logdir" / --mmin -1440 -name "log.crit.*" | cut f6 -d"/" | sort -n | tail -n 5
    echo ""
    echo "Which Critical Logs do you want to see? (Newest at Bottom) "
    read crit
      if [[ "$crit" =~ log.crit.* ]]; then
        grep 'ERROR' "$logdir"/"$crit" | cut -f3-6 -d' ' | sort -k4 -u
        echo ""
      else
        echo ""
        echo "******************************"
        echo "That's not a Critical Log file!!!"
        echo "******************************"
      fi
    echo ""
    echo "Do you want to look at more logs: [Y]es/[N]o"
    read answer
      if [[ "$answer" == [Nn][Oo] ]] || [[ "$answer" == [Nn] ]]; then
        exit
      elif [[ "$answer" == [Yy][Ee][Ss] ]] || [[ "$answer" == [Yy] ]]; then
        continue
      fi
  fi
  
  if [[ "$choice" == "5" ]]; then
    echo ""
    echo "Here's the last 5 Debug Logs from the last 24-hrs:  "
    find "$logdir" / --mmin -1440 -name "log.debug.*" | cut f6 -d"/" | sort -n | tail -n 5
    echo ""
    echo "Which Debug Logs do you want to see? (Newest at Bottom) "
    read debug
      if [[ "$debug" =~ log.debug.* ]]; then
        grep 'ERROR' "$logdir"/"$debug" | cut -f1-10 -d' ' | sort -k2,2 -k5 -u
        echo ""
      else
        echo ""
        echo "******************************"
        echo "That's not a Debug Log file!!!"
        echo "******************************"
      fi
    echo ""
    echo "Do you want to look at more logs: [Y]es/[N]o"
    read answer
      if [[ "$answer" == [Nn][Oo] ]] || [[ "$answer" == [Nn] ]]; then
        exit
      elif [[ "$answer" == [Yy][Ee][Ss] ]] || [[ "$answer" == [Yy] ]]; then
        continue
      fi
  fi
  
  if [[ "$choice" == "0" ]]; then
    exit
  fi
  
  if [[ "$choice" != "012345" ]]; then
    echo ""
    echo "******************Invalide Choice******************"
    echo ""
    sleep 5
  fi
done
