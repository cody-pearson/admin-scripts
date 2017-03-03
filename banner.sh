#!/bin/bash 
#========================================================== 
# title             :banner.sh 
# description       :setup classification banner on RHEL 
# author            :Pearson 
# date              :2017 Mar 3 
# version           :1.1
# usage             :bash banner.sh or ./banner.sh 
# notes             :Should only be 1 classification needed 
# TODO              :1) Better error checking 
#                    2) Make all options viable
#==========================================================

## Variables
now=$(date +%Y%m%d_%H%M%S)
banner_path=/path/to/config/dir

## Run as root
if [[ "$UID" -ne 0 ]]; then
  echo "This script must be ran as root..."
  exit
fi

## Checking for previous classification-banner
echo "checking /etc/classification-banner..."
  if [[ -f /etc/classification-banner ]]; then
    rm -f /etc/classification-banner
  fi

## Determine CLASSIFICATION of machine
if [[ ! -f /etc/classification-banner ]]; then
  CLASS_ANS="N"
    until [[ "$CLASS_ANS" = "Y" ]]; do
      echo "What is the classification of this machine ([U]/S/T)?"
      read answer
        if [[ "$answer" = "S" ]] || [[ "$answer" = "s" ]]; then
          CLASSIFICATION="SECRET"
          CLASSLOGO="red"
          CLASS_COLORS="echo -e fgcolor = '#FFFFFF'\nbgcolor = '#FF0000'"
        elif [[ "$answer" = "T" ]] || [[ "$answer" = "t" ]]; then
          CLASSIFICATION="TS-SCI"
          CLASSLOGO="gold"
          CLASS_COLORS="echo -e bgcolor = '#FFFF00'"
        else
          CLASSIFICATION="UNCLASSIFIED"
          CLASSLOGO="green"
        fi
        
        read -p "Is $CLASSIFICATION corrrect"   ans1
          if [[ "$ans1" == [Yy][Ee][Ss] ]] || [[ "$ans1" == [Yy] ]]; then
            CLASS_ANS="Y"
          fi
    done
fi

## Place classification-banner on system
if [[ ! -f /usr/local/bin/classification-banner.py ]]; then
  echo "installing classification-banner.py"
    cp "$banner_path"/classification-banner.py /usr/local/bin/classification-banner.py
    chown root:root /usr/local/bin/classification-banner.py
    chmod 755 /usr/local/bin/classification-banner.py
else
  echo "classification-banner is already on the system"
fi    

## Auto start classification-banner 
if [[ ! -f /etc/xdg/autostart/classification-banner.desktop ]]; then
  echo "Setting classification-banner to autostart"
    cp "$banner_path"/classification-banner.desktop /etc/xdg/autostart/classification-banner.desktop
    chown root:root /etc/xdg/autostart/classification-banner.desktop
    chmod 644 /etc/xdg/autostart/classification-banner.desktop
fi

## Checking for background image
if [[ -z "$(egrep 'System Banner' /usr/share/backgrounds/default.xml)" ]]; then
  echo "- installing gdm login background"
    cp /usr/share/backgrounds/default.xml /usr/share/backgrounds/default.xml."$now"
    cp "$banner_path"/default.xml /usr/share/backgrounds/default.xml
    chmod 644 /usr/share/backgrounds/default.xml
fi

## Setting system classification information
if [[ -f /etc/classification-banner ]] && [[ ! -z "$CLASSIFICATION" ]]; then
  echo "- updating /etc/classification-banner with $CLASSIFICATION"
    cp /etc/classification-banner /etc/classification-banner."$now"
    cat > /etc/classification-banner <<EOF
message = '$CLASSIFICATION'
$($CLASS_COLORS)
EOF
fi
  
## Update background with selected classification
echo "- updating gdm login background"
  cp /usr/share/backgrounds/default.xml /usr/share/backgrounds/default.xml."$now"
  sed -ci -e "/1200_green/ s/green/$CLASSLOGO/" /usr/share/backgrounds/default.xml
  chmod 644 /usr/share/backgrounds/default.xml
