#!/bin/bash 
#==========================================================
#title           :chg_system.sh
#description     :initial system setup
#author          :Pearson
#date            :2017 Feb 5
#version         :1.0    
#usage           :bash chg_system.sh or ./chg_system.sh
#notes           :hostname and/or networking changes
#todo            : 1) Handle more than 1 NIC
#==========================================================

## Variables (part 1)
nic_search=$(find /etc/sysconfig/network-scripts/ -name "ifcfg-*" | grep -v lo)
cur_nic_file="$nic_search"
nic_count=$(find /etc/sysconfig/network-scripts/ -name "ifcfg-*" | grep -v lo | wc -l)
short_nic==$(find /etc/sysconfig/network-scripts/ -name "ifcfg-*" | grep -v lo | cut -d"-" -f3-)

## Run as root
if [[ "$UID" != 0 ]]; then
  echo "***ERROR*** You need to be root to run this script"
  exit
fi

## Count NICs
if [[ "$nic_count" -gt 1 ]]; then
  echo "***ERROR*** This script currently only works on 1 NIC"
  echo "***ERROR*** NICs found:  "$short_nic"  "
  exit
elif [[ "$nic_count" -eq 0 ]]; then
  echo "***ERROR*** There were no NICs found  "
  exit
else
  echo "This is the NIC that will be modified:  "$cur_nic"  "
fi

## Variables (part 2)
hosts="/etc/hosts"
network="/etc/sysconfig/network"
cur_host=$(hostname)
cur_ip=$(grep ^IPADDR= "$cur_nic_file" | cut -d"=" -f2 | tr -d '\"')
cur_gw=$(grep ^GATEWAY= "$network" | cut -d"=" -f2 | tr -d '\"')
cur_mask=$(grep ^NETMASK= "$cur_nic_file" | cut -d"=" -f2 | tr -d '\"') 
cur_mtu=$(grep ^MTU= "$cur_nic_file" | cut -d"=" -f2 | tr -d '\"')
now=$(date "+%y%m%d_%H%M%S")

## Check current GW
if [[ -z "$cur_gw" ]]; then
  cur_gw="$cur-ip"
fi

## Check MTU size
if [[ -z "$cur_mtu" ]]; then
  cur_mtu=$(ifconfig "$cur_nic" | grep -o "MTU:[0-9]*[^0-9]" | cut -d":" -f2)
fi

## Output current findings
echo ""
echo "Current network settings for:  ("$cur_nic") "
echo "  Current Hostname:       $cur_host "
echo "  Current IP:             $cur_ip "
echo "  Current Netmask:        $cur_mask "
echo "  Current Gateway:        $cur_gw "
echo "  Current MTU:            $cur_mtu "
echo ""

read -p "Do you want to change any of these network settings ([y]/n)? " answer
  if [[ "$answer" != [Yy][Ee][Ss] ]] | [[ "$answer" != [Yy] ]]; then
    exit
  fi
  
## Loop through Network Settings
ok=0
while [[ "$ok" != 1 ]]; do
  echo "    Current Hostname:  $cur_host"
  read -p "Enter the new hostname (Enter to keep current Hostname):  " newhost
    if [[ -z "$newhost" ]]; then
      newhost="$cur_host"
    fi
      echo "Hostname is now: "$newhost"  "
      echo ""
  
  echo "    Current IP:  $cur_ip"
  read -p "Enter the new IP address (Enter to keep current IP):  " newip
    if [[ -z "$newip" ]]; then
      newip="$cur_ip"
    fi
      echo "IP is now: "$newip"  "
      echo ""
   
  echo "    Current Netmask:  $cur_mask"
  read -p "Enter the new Netmask (Enter to keep current Netmask):  " newmask
    if [[ -z "$newmask" ]]; then
      newmask="$cur_mask"
    fi
      echo "Netmask is now: "$newmask"  "
      echo ""
      
  echo "     Current Gateway:  $cur_gw"
  read -p "Enter the new Gateway (Enter to keep current Gateway):  " newgw
    if [[ -z "$newgw" ]]; then
      newgw="$cur_gw"
    fi
      echo "Gateway is now: "$newgw"  "
      echo ""
      
  echo "    Current MTU: $cur_mtu"
  read -p "Enter the new MTU (Enter to keep current MTU):  " newmtu
    if [[ -z "$newmtu" ]]; then
      newmtu="$cur_mtu"
    fi
      echo "MTU is now: "$newgw"  "
      echo ""
      
## Output network settings from user input
  echo ""
  echo "Update network settings for: ("$cur_nic") "
  [[ "$cur_host" != "$newhost" ]] && echo "  Hostname:       "$newhost" "
  [[ "$cur_ip"   != "$newip"   ]] && echo "  IP:             "$newip"   "
  [[ "$cur_mask  != "$newmask" ]] && echo "  Netmask:        "$newmask" "
  [[ "$cur_gw"   != "$newgw"   ]] && echo "  Gateway:        "$newgw"   "
  [[ "$cur_mtu"  != "$newmtu"  ]] && echo "  MTU:            "$newmtu"  "
  echo ""
  
  read -p "Do you want to change the host/ip/nm/gw/mtu now? (Yes/No/Quit) ans1
    if [[ "$ans1" = [Yy][Ee][Ss] ]] | [[ "$ans1" = [Yy] ]]; then
      ok=1
    elif [[ "$ans1" = [Qq][Uu][Ii][Tt] ]] | [[ "$ans1" = [Qq] ]]; then
      exit
    elif [[ "$ans1" = [Nn][Oo] ]] | [[ "$ans1" = [Nn] ]]; then
      continue
    else
      echo ""
      echo "Please try again. "
      echo ""
      continue
    fi
done
  
## Apply network changes from previous input
if [[ "$ans1" = [Yy][Ee][Ss] ]] | [[ "$ans1" = [Yy] ]]; then
## Update Hostname  
  if [[ "$newhost" = "$cur_host" ]]; then
    echo "No change in hostname"
  else
    echo "Changing hostname to $newhost"
      if [[ -f "$network" ]]; then
        cp -p "$network" "$network"."$now"
      fi
        echo "Updating "$newhost" in "$network" "
        sed -ci -e "/^HOSTNAME/s/$cur_host/$newhost/" $network > /dev/nul
  fi
## Update Hostname in /etc/hosts
  if [[ -f "$hosts" ]]; then
    cp -p "$hosts" "$hosts"."$now"
      if [[ ! -z $(grep -w \"${cur_ip}\s*${cur_host}\" "$hosts") ]]; then
        echo "Updating "$newhost" in "$hosts" "
        sed -ci -e "/^$cur_ip/s/$cur_host/$newhost/" "$hosts" > /dev/null
      else
        echo "Adding "$newhost" to "$hosts"  "
        echo ""$newip"    "$newhost" >> "$hosts"
      fi
  fi
fi

## Check/Update IP Address
if [[ "$newip" = "$cur_ip" ]]; then
  echo "No change in IP"
else
  echo "Changing IP to "$newip"  "
    if [[ -f "$cur_nic_file" ]]; then
      cp -p "$cur_nic_file" "$cur_nic_file"."$now"
    fi
      echo "Updating IP Address in "$cur_nic_file"  "
      sed -ci -e "/^IPADDR/s/$cur_ip/$newip/" "$cur_nic_file" > /dev/null
fi      

## Check/Update IP Address in /etc/hosts
if [[ -f "$hosts" ]] & [[ ! -f "$hosts"."$now" ]]; then
  cp -p "$hosts" "$hosts"."$now"
fi
  echo "Updating "$newip" in "$hosts"
  sed -ci -e "/^$cur_ip/s/$cur_ip/$newip/" "$hosts" > /dev/null
  
## Check/Update Subnet Mask
if [[ "$newmask" = "$cur_mask" ]]; then
  echo "No change in Netmask"
else
  echo "Changing Netmask to "$newmask"  "
    if [[ -f "$cur_nic_file" ]] && [[ ! -f "$cur_nic_file"."$now" ]]; then
      cp -p "$cur_nic_file" "$cur_nic_file"."$now"
    fi
      echo "Updating NETMASK in "$cur_nic_file"  "
      sed -ci -e "/$NETMASK/s/$cur_mask/$newmask/" "$cur_nic_file" > /dev/null
fi

## Check/Update Gateway
if [[ "$newgw" = "$cur_gw" ]]; then
  echo "No change in GW"
else
  echo "Updating GW "
    if [[ -f "$network" ]] && [[ ! -f "$network"."$now" ]]; then
      cp -p "$network" "$network"."$now"
    fi
      echo "Updating GW in "$network"
    if [[ -z $(grep GATEWAY "$network") ]]; then
      echo "GATEWAY=\"$newgw\"" >> "$network"
    else
      sed -ci -e "/^GATEWAY/s/$cur_gw/$newgw/" "$network" > /dev/null
    fi
    
    if [[ ! -z $(grep GATEWAY "$cur_nic_file" ]]; then
      if [[ -f "$cur_nic_file" ]] && [[ ! -f "$cur_nic_file"."$now" ]]; then
        cp -p "$cur_nic_file" "$cur_nic_file"."$now"
      fi
        echo "Removing GATEWAY from "$cur_nic_file"  "
        sed -ci -e "/^GATEWAY/d" "$cur_nic_file" > /dev/null
    fi
fi

## Check/Update MTU
if [[ "$newmtu" = "$cur_mtu" ]]; then
  echo "No change in MTU"
else
  echo "Changing MTU to "$newmtu"  "
    if [[ -f "$cur_nic_file" ]] && [[ ! -f "$cur_nic_file"."$now" ]]; then
      cp -p "$cur_nic_file" "$cur_nic_file"."$now"
    fi
      echo "Updating MTU in "$cur_nic_file"  "
      sed -ci -e "/^MTU/s/$cur_mtu/$newmtu/" "$cur_nic_file > /dev/null
        if [[ -z $(grep ^MTU "$cur_nic_file") ]]; then
          echo "MTU="$newmtu"" >> "$cur_nic_file"
        fi
fi

## Check for loopback address in /etc/hosts
grep "^127.0.0.1/s/127.0.0.1.*/127.0.0.1\tlocalhost/" "$hosts" > /dev/null
  if [[ "$?" -ne 0 ]]; then
    sed -ci -e "^127.0.0.1/s/127.0.0.1.*/127.0.0.1\tlocalhost/" "$hosts" > /dev/null
    echo "Updated localhost line in "$hosts"  "
  fi

## Check/Remove IPv6 loopback address in /etc/hosts
grep "^::1\s*localhost/D" "$hosts" > /dev/null
  if [[ "$?" -eq 0 ]]; then
    sed -ci -e "/^::1\s*localhost/D" "$hosts" > /dev/null
    echo "Removed IPv6 ::1 localhost line in "$hosts"  "
  fi
  
## Find extra NIC config files in /etc/sysconfig/network-scripts
extra_nic=$(find /etc/sysconfig/network-scripts/ -name "*"$cur_nice".*")
  if [[ "$nic_count -gt 0 ]]; then
    echo "Moving "$extra_nic" to /tmp"
    echo "Otherwise, it looks like a duplicate interface"
    mv "$extra_nic" /tmp
  fi
 
## Restart network daemon
echo ""
echo "In order for your changes to take effect immediately, the network"
echo "will need to be restarted."
echo "WARNING! If you are logged in remotely, restarting the network"
echo" will cause your connection to close/drop. "
echo ""
  read -p "Do you want to restart networking now? [Y]/[N]   "    ans2
    if [[ "$ans2" = [Yy][Ee][Ss] ]] | [[ "$ans2" = [Yy] ]];then
      if [[ ! -z "$extra_nic" ]]; then
        echo "Moving "$extra_nic" to /tmp"
        echo "Otherwise, it looks like a duplicate interface"
        mv "$extra_nic" /tmp
      fi
        /etc/init.d/network restart
    else
      echo "***INFO*** Please restart the network daemon ASAP  "
      exit
    fi
