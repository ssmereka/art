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
    pingTest
    if [[ "$?" -le "0" ]]; then
      ipTest
      if [[ "$?" -le "0" ]]; then
        if $debug; then
          echo "VPN Status:  OK $curIp   $(date)"
        fi
      fi
    fi
  fi
}

# Check if the IP address has changed or not.
function ipTest {
  curIp=`curl -s icanhazip.com`
  if [[ "$curIp" == "" ]]; then
    handleFailure "Error: VPN is not working, could not get IP address."
    return 1
  fi

  if [[ "$ip" == "$curIp" ]]; then
    handleFailure "Error:  VPN is not working, IP address is unchanged."
    return 1
  fi
  
  return 0
}

# Perform a ping test to ensure the vpn is working correctly.
function pingTest {
  if $debug; then
    ping -c1 -w1 4.2.2.2 | grep PING
  else
    ping -q -c1 -W 250 4.2.2.2 1>/dev/null 2>&1
  fi

  if [ "$?" -ne "0" ]; then
    pingFailureCount=0
  
    while [ $pingFailureCount -le 4 ]; do
      sleep 1
    
      if $debug; then
        ping -c1 -w1 4.2.2.2 | grep PING
      else
        ping -q -c1 -W 250 4.2.2.2 1>/dev/null 2>&1
      fi
      
      if [ "$?" -ne "0" ]; then
        let pingFailureCount=pingFailureCount+1
      else
        break
      fi
    done

    if [[ $pingFailureCount > 5 ]]; then
      handleFailure "VPN is not working, no data is being transfered."
      return 1
    elif $debug; then
      return 0
    fi
  fi

  return 0
}

# Star openvpn with the specified config file.
function startVpn {
  sudo echo -e "nameserver 184.75.220.106\nnameserver 89.248.172.121" > "/etc/resolv.conf"

  echo "Starting openvpn with config "$vpnConfigFile
  
  echo "openvpn --config "$vpnConfigFile > $openvpnLog
  echo -e "----------------------------------------\n" >> $openvpnLog

  sudo openvpn --config $vpnConfigFile >> $openvpnLog &
}

function stopVpn {
  # Kill the openvpn server.
  openvpnPid=`pgrep openvpn`
  if [[ "$openvpnPid" != "" ]]; then
    echo -ne "\nKilling openvpn process...\n"
    sudo kill -9 `pgrep openvpn`
    echo -ne "\nKilling openvpn process...\t[ DONE ]\n\n"
  fi
}

function restartVpn {
  echo -ne "\nRestarting VPN...\n"
  stopMonitorServiceFlag=true
  stopVpn
  sleep 10
  #ip=`curl -s icanhazip.com`
  startMonitorService
  echo -ne "\nRestarting VPN...\t[ DONE ]\n\n"
}

# Notify of failure.
function notifyFailure {
 echo fuck
}

function handleFailure {
  if [[ "$1" != "" ]]; then 
    echo $1
  fi

  notifyFailure
  restartVpn
}

stopMonitorServiceFlag=false

function startMonitorService {
  stopMonitorServiceFlag=false
  while [ 1 ]; do
    if $stopMonitorServiceFlag; then
      break
    fi

    monitorOpenVpn
    
    sleepCounter=0;
    while [ $sleepCounter -le 59 ]; do
      if $stopMonitorServiceFlag; then
        break
      else
        sleep 1
        let sleepCounter=sleepCounter+1
      fi
    done
  done
}


# ----------------------------------------- #
# Script Logic
# ----------------------------------------- #

startMonitorService
