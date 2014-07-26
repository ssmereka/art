#!/bin/bash

# ----------------------------------------- #
# Script Configuration
# ----------------------------------------- #

vpnConfigFile=$1
ip=$4
openvpnLog=$2
debug=$3


# ----------------------------------------- #
# Stop - Don't change anything below - Stop
# ----------------------------------------- #




# ----------------------------------------- #
# Global Variables
# ----------------------------------------- #


# ----------------------------------------- #
# Set Defaults
# ----------------------------------------- #

# Default openvpn config file.
if [[ "$vpnConfigFile" == "" ]]; then
  vpnConfigFile="./openvpnConfig.ovpn"
fi

# Default ip address to an invalid address.
if [[ "$ip" == "" ]]; then
  ip=127.0.0.1
fi

# Default openvpn log file.
if [[ "$openvpnLog" == "" ]]; then
  openvpnLog="./openvpn.log"
fi

# Default to debug off.
if [[ "$debug" != "true" ]] && [[ "$debug" != "false" ]]; then
  debug=false
fi


# ----------------------------------------- #
# VPN Methods
# ----------------------------------------- #

# Start monitoring openvpn, starting openvpn if it stops.
function monitorOpenVpn {
  
  # If openvpn is not running, start it.
  openvpnPid=`pgrep openvpn`
  if [[ $openvpnPid == "" ]]; then
    ip=`curl -s icanhazip.com`
    startVpn
  else
    curIp=`curl -s icanhazip.com`
    if [[ "$ip" == "$curIp" ]]; then
      echo "Error:  VPN is not working, IP address is unchanged."
      #notifyFailure
    elif $debug; then
      echo "VPN Status:  OK $curIp   $(date)"
    fi
  fi
}

# Star openvpn with the specified config file.
function startVpn {
  sudo echo -e "nameserver 184.75.220.106\nnameserver 89.248.172.121" > "/etc/resolv.conf"

  echo "Starting openvpn with config "$vpnConfigFile
  
  echo "openvpn --config "$vpnConfigFile > $openvpnLog
  echo -e "----------------------------------------\n" >> $openvpnLog

  sudo openvpn --config $vpnConfigFile >> $openvpnLog &
}

# Notify of failure.
function notifyFailure {
 echo fuck
}


# ----------------------------------------- #
# Script Logic
# ----------------------------------------- #

while [ 1 ]
do
  monitorOpenVpn
  sleep 60
done
