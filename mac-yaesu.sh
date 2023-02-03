#!/bin/bash
#
###################################################################################################
###################################################################################################
# This script was created to address the annoying issue of identifying the correct /dev/cu.SLAB_USBtoUARTx for Yaesu FT-891 & FT-991A radios attached to a Mac running macOS Monterrey.
# It requires Hamlib to be installed on the system. Hamlib can be easily installed using hombrew (https://brew.sh): brew install hamlib
#
# 
# If flrig is installed and enabled (see user configurable settings), the script will launch an instance per radio. 
# flrig must have been manually launched and initially configured once per radio prior to enabling flrig in the user configurable settings. 
# To manually launch flrig– Open terminal and type: open -a /Applications/flrig.app --args --config-dir ~/Documents/Yaesu/891 (or 991A)
# The folders ~/Documents/Yaesu/891 & ~/Documents/Yaesu/991A must be manually created by the user prior to running the above command.
#
# flrig can also be installed with hombrew: brew install --cask flrig
#
# When enabled, the script will launch rigctld instance per radio. 
# 
###################################################################################################
###################################################################################################
# User configurable settings / preferences

# All radios must be set to the following CAT Rate
BAUD=9600

# Enable rigctld (0 = No, 1 = Yes), disable if more than two radios are attached to the Mac
RIGCTLD_ENABLE=1

# Launch flrig ( 0= No, 1 = Yes), disable if more than two radios are attached to the Mac, or if two same model radios 
FLRIG_ENABLE=1

###################################################################################################
# Confirm rigctl is installed, and if enabled will terminate any running instances of both rigctl and rigctld
RIGCTL=$(which rigctl); ec=$?
if [[ $ec != 0 ]]; then
  echo "Rigctl not found!"
  exit 1;
elif [[ $RIGCTLD_ENABLE = 1 ]]; then
  killall -9 rigctl >/dev/null 2>&1
  killall -9 rigctld >/dev/null 2>&1;
fi

RIGCTLD=$RIGCTL"d"

# Confirm SL CP210x devices are recognized by macOS 
if [[ ! -c "/dev/cu.SLAB_USBtoUART" ]]; then
  echo "No devices found!"
  exit 1;
fi

# Confirm FLRig is installed, and if enabled will terminate any running instances
FLRIG=$(mdfind -name 'flrig' -onlyin /Applications)
if [[ $FLRIG = "" ]]; then
  echo "FLRig not found!"
elif [[ $FLRIG_ENABLE = 1 ]]; then
  killall -9 flrig >/dev/null 2>&1
fi


# The following section matches /dev/cu.SLAB_USBtoUART identifiers to corresponding Yaesu 891 or 991A radios,
# updates the FLrig xcvr serial port preferences accordingly, launches FLRig (if installed) and rigctld instances (one per radio). 
for RADIO in /dev/cu.SLAB_USBtoUART*; do
 INFO=$(rigctl -m 1035 -r $RADIO -s $BAUD get_info 2>/dev/null); ec=$?
 if [[ $ec = 0 ]]; then
   POWERON=$(rigctl -m 1035 -r $RADIO -s $BAUD set_powerstat 1); ec=$?;
   INFO=$(rigctl -m 1035 -r $RADIO -s $BAUD get_info); ec=$?;
   echo "Radio $INFO found at $RADIO"
   if [[ $FLRIG != "" && $FLRIG_ENABLE = 1 ]]; then
     case $INFO in
       ID0650) # ID information can be found in manufacturer and model specific CAT documentation  
         sed -i.bu "s|xcvr_serial_port:.*|xcvr_serial_port:$RADIO|g" ~/Documents/Yaesu/891/FT-891.prefs 
         sed -i.bu "s|xmlport:.*|xmlport:12345|g" ~/Documents/Yaesu/891/FT-891.prefs 
         open -n -a $FLRIG --args --config-dir ~/Documents/Yaesu/891
         [[ $RIGCTLD_ENABLE -eq 1 ]] && nohup $RIGCTLD -m 4 -r localhost:12345 --port=4532 >/dev/null 2>&1 &
       ;;
       ID0670) 
         sed -i.bu "s|xcvr_serial_port:.*|xcvr_serial_port:$RADIO|g" ~/Documents/Yaesu/991A/FT-991A.prefs 
         sed -i.bu "s|xmlport:.*|xmlport:12346|g" ~/Documents/Yaesu/891/FT-891.prefs 
         open -n -a $FLRIG --args --config-dir ~/Documents/Yaesu/991A
         [[ $RIGCTLD_ENABLE -eq 1 ]] && nohup $RIGCTLD -m 4 -r localhost:12346 --port=4533 >/dev/null 2>&1 &
       ;;
     esac
   fi
 else
   echo "No radio found at $RADIO"
fi 
done
