#!/bin/bash

# ----------------------------------------- #
# Script Configuration
# ----------------------------------------- #

vpnUsername=""
vpnPassword=""

logFile=./log
ip="68.43.136.40"
debug=false
openvpnLogFile="./ovpn.log"
authFile="./auth.txt"

# ----------------------------------------- #
# Stop - Don't change anything below - Stop
# ----------------------------------------- #




# ----------------------------------------- #
# Global Variables
# ----------------------------------------- #

vpnMonitorProcessName="vpnmon.sh"
vpnMonitorScript="./vpnmon.sh"
openvpnConfigFolder="./TorGuardPRO"
openVpnConfigFile="./TorGuardPRO/TorGuard.Sweden.ovpn"
isRunAsRoot=false
isLoggingOn=false

# ----------------------------------------- #
# Authentication Script Methods
# ----------------------------------------- #

# Get the user's vpn credentials
function getVpnCredentials {
  # Get vpn credentials
  if [[ "$vpnUsername" == "" ]]; then
    echo -n "VPN username: "
    read vpnUsername
  fi

  if [[ "$vpnPassword" == "" ]]; then
    echo -n "VPN password: "
    stty_original=`stty -g`
    stty -echo
    read vpnPassword
    stty $stty_original
    echo
  fi
}

# Create an authentication file.
function createAuthFile {
  if [ ! -f $authFile ]; then
    sudo echo -e $vpnUsername"\n"$vpnPassword > $authFile
    chown root:root $authFile
    chmod 400 $authFile
  fi
}



# ----------------------------------------- #
# End Script Methods
# ----------------------------------------- #

# Exit the script.
function end {
  vpnUsername=""
  vpnPassword=""
  exit
}


# ----------------------------------------- #
# Log Methods
# ----------------------------------------- #

# Create a new log file and start logging output of script to that file.
function startLogging {
  echo -e "----------------------------------------" > $logFile
  echo -e "Log Start" >> $logFile
  echo -e "----------------------------------------\n" >> $logFile
  exec 3>&1 1>>${logFile} 2>&1
  isLoggingOn=true
}

# Start logging output of script to the already existing log file.
function continueLogging {
  exec 3>&1 1>>${logFile} 2>&1
  isLoggingOn=true
}


# ----------------------------------------- #
# Print Methods
# ----------------------------------------- #

# Print help menu.
function printHelp {
  echo -e "usage: \tbox.sh [options]\n"
  
  echo -e "options:"
  echo -e "  -d \t debug  \t Toggle on debug mode to display extra logs."
  echo -e "  -k \t kill   \t Kill the vpn and monitoring service."  
  echo -e "  -l \t list   \t List the available vpns to connect to."
  echo -e "  -s \t start  \t Start vpn and monitoring service."
  echo -e "  -u \t update \t Update the current list of vpns."
  echo
}

# Print the start of a task to console and file.
function printJob {
  currentJob=$1
  echo "----------------------------------------"
  echo -e $1"...\n"
  echo -ne $1"..." 1>&3
}

# Print the completion message for the current task to the console and to file.
function printJobDone {
  job=$1
  if [[ "$job" == "" ]]; then  
    job=$currentJob
    currentJob=""
  fi
  
  echo 
  echo -e $job"...\t[ DONE ]"
  echo -e "----------------------------------------\n"
  echo -ne "\t[ DONE ]\n" 1>&3
}

# Print to the console only.
function printConsole {
  echo $* 1>&3
}

# Print the log file to the console only.
function printLogs {
  if $isLoggingOn; then
    cat $logFile 1>&3
  else
    cat $logFile
  fi
}

# Print to the console and file.
function print {
  echo -e $1 | tee /dev/fd/3
}

# Print to the console and file on the same line.
function printSameLine {
  echo -ne $1 | tee /dev/fd/3
}

# Tail log file
function tailLogs {
  tail -f $logFile
}


# ----------------------------------------- #
# Root Methods
# ----------------------------------------- #

function requireRootPermission {
  if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo: "
    echo "sudo $0 $*"
    end
  else
    isRunAsRoot=true
  fi
}


# ----------------------------------------- #
# VPN Methods
# ----------------------------------------- #

# Ensure openvpn and its config files are installed.
function installOpenvpn {
  # Ensure openvpn is installed.  
  if [[ `which openvpn` == "" ]]; then
    printJob "Installing openvpn"
    sudo apt-get update
    sudo apt-get install upgrade -y --force-yes
    sudo apt-get install openvpn openssl -y --force-yes
    printJobDone
  fi

  # Ensure openvpn configs are downloaded.
  if [[ ! -d "$openvpnConfigFolder" ]]; then
    updateVpnList
  fi
}

# Start a monitor that will ensure the VPN is up and running.
function startMonitor {
  printJob "Starting vpn monitor"
  $vpnMonitorScript $openVpnConfigFile $ip $openvpnLogFile $debug &
  printJobDone
}

# Stop the vpn and the monitor.
function stopMonitor {
  # Kill the openvpn monitor  
  printJob "Killing openvpn monitor"
  killall $vpnMonitorProcessName
  printJobDone
  
  # Kill the openvpn server.
  openvpnPid=`pgrep openvpn`
  if [[ "$openvpnPid" != "" ]]; then
    printJob "Killing openvpn"
    sudo kill -9 `pgrep openvpn`
    printJobDone
  fi
}

# Update the current list of vpn configurations from torguard.
function updateVpnList {
  # Install unzip if we need to.
  if [[ `which unzip` == "" ]]; then
    printJob "Installing unzip package"
    sudo apt-get install unzip
    printJobDone
  fi

  printJob "Updating VPN list"
  
  if [ -f $openvpnConfigFolder".zip" ]; then
    echo "Removing old configuration zip folder."
    sudo rm $openvpnConfigFolder".zip"
  fi
  
  if [ -f $openvpnConfigFolder ]; then
    echo "Removing old configurations folder."
    sudo rm -rf $openvpnConfigFolder
  fi

  wget "https://torguard.net/downloads/"$openvpnConfigFolder".zip"
  unzip $openvpnConfigFolder".zip"
  cd $openvpnConfigFolder
  sed -i -e 's/auth-user-pass/auth-user-pass auth.txt/' *.ovpn
  cd ../
  printJobDone
}

# ----------------------------------------- #
# Script Logic
# ----------------------------------------- #

# Handle script flags.
for var in "$@"
do
  case "$var" in
    -d | -debug | [debug])
      debug=true
      ;;

    -k | -kill | [kill])
      continueLogging      
      stopMonitor
      end
      ;;
 
    -l | -list | [list])
      
      end
      ;;
   
    -p | -print | [print])
      tailLogs
      end
      ;;

    -s | -start | [start])
      requireRootPermission
      getVpnCredentials
      startLogging
      installOpenvpn
      createAuthFile
      startMonitor
      end
      ;;
    
    -u | -update | [update])
      startLogging
      updateVpnList
      printLogs
      end
  esac
done

# If no options are specified, print the help menu.
printHelp

# End the script
end