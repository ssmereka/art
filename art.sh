#!/bin/bash

# Anonymous Raspberry Torte
#
# TORte, TOR-te, TORreTE, Torrent... huh? 
# do... do you get it?
#
# This script will setup your pi to use a vpn 
# for all traffic ensuring your anonymity.  
# It will also monitor your IP address to 
# ensure the vpn is working correctly.


# ----------------------------------------- #
# Script Configuration
# ----------------------------------------- #

# If you want, if you really really want,
# if you really really wanta configure this
# script... you can do so below.

# Your IP address goes here.  Don't worry
# the script will keep this updated for you,
# but just to be safe.
#
# Recommendation... go to http://icanhazip.com
# copy your IP address and paste it in here.
# 
ip=""

# Private VPN username.  If you do not enter 
# it here you will be prompted the first time
# you start openvpn using this script.
#
# Recommendation... leave it blank
#
vpnUsername=""

# Private VPN password.  If you do not enter 
# it here you will be prompted the first time
# you start openvpn using this script.
#
# Recommendation... leave it blank
#
vpnPassword=""

# When true, additional logs will be printed.
#
# Recommendation... leave this as false.
#
debug=false

# Directory where this script is stored.
#
# Recommendation... leave this alone.
#
scriptRootDirectory="/usr/bin/art"

# Script log file location.
#
# Recommendation... leave this alone.
#
logFile=$scriptRootDirectory"/torbox.log"

# Openvpn log file location.
#
# Recommendation... leave this alone.
#
openvpnLogFile=$scriptRootDirectory"/ovpn.log"

# VPN credentials storage location.
#
# Recommendation... leave this alone.
#
authFile=$scriptRootDirectory"/auth.txt"


# VPN Provider 
# ----------------------------------------- #
# There are tons of VPN providers out there 
# and this script will automatically setup
# openvpn for your provider, maybe.  You 
# should indicate, from the immense list of
# providers below, which one you would like 
# to use.

# Immense list of possible VPN providers:
torguard="TorGuard"

# Selected VPN provider
# Fill in the provider you would like to use.
vpnProvider=$torguard


# ----------------------------------------- #
# Stop - Don't change anything below - Stop
# ----------------------------------------- #






# or whatever, what do I care.  Just don't
# come crying to me about unexpected features
# you introduced into the script because I 
# already added tons of those for you!


# ----------------------------------------- #
# Global Variables
# ----------------------------------------- #

# Files
# ----------------------------------------- #
# Below are all file related variables, such 
# as names, locations, etc.

# Current directory this script is in.
curScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# File name of this script.
artScriptName="art.sh"

# Location of this script.
artScript=$scriptRootDirectory"/"$artScriptName

# File name of the openvpn monitor script.
vpnmonScriptName="vpnmon.sh"

# Location of the openvpn monitor script.
vpnMonitorScript=$scriptRootDirectory"/"$vpnmonScriptName


# Flags
# ----------------------------------------- #
# Below are boolean values used to track
# functionality or turn it on/off.

# Is the script output currently being logged to a file
isLoggingEnabled=false

# Is the script run as root
isRoot=false

# Is the package manager updated or not.
isPmUpdated=false


#  Cached Values
# ----------------------------------------- #
# Other misc values used by the entire script
# are listed here.

# Name of the current task being performed.
currentJob=""


# VPN Provider
# ----------------------------------------- #
# Global variables related to the use of 
# openvpn with a specific provider.

# Openvpn configuration folder, stores all the configs.
if [[ "$vpnProvider" == "$torguard" ]]; then
  openvpnConfigFolder=$scriptRootDirectory"/TorGuardPRO"
  openVpnConfigFile=$openvpnConfigFolder"/TorGuard.Sweden.ovpn"
else
  end "Invalid VPN provider selected."
fi


# ----------------------------------------- #
# Authentication Methods
# ----------------------------------------- #

# Get the user's vpn credentials
function getVpnCredentials {
  if [[ "vpnUsername" == "" ]]; then
    getUserInput $vpnUsername $vpnProvider" VPN username: "
  fi

  if [[ "vpnPassword" == "" ]]; then
    getUserInputHidden $vpnPassword $vpnProvider" VPN password: "
  fi
}

# Create an authentication file.
function updateAuthFile {
  # Ensure script has root permission.
  requireRootPermission

  # Ensure vpn username and password are stored.
  getVpnCredentials
  
  # Remove the old auth file.
  if [ -f $authFile ]; then
    sudo rm $authFile
  fi
  
  # Create the new auth file with the proper permissions.
  sudo echo -e $vpnUsername"\n"$vpnPassword > $authFile
  sudo chown root:root $authFile
  sudo chmod 400 $authFile
}

# Ensure the auth file exists, otherwise create it.
function requireAuthFile {
  if [ ! -f $authFile ]; then
    updateAuthFile
  fi 
}


# ----------------------------------------- #
# User Input Methods
# ----------------------------------------- #

# Get user input
function getUserInput {
  # Flag to indicate we turned off logging 
  # to a file or not.
  weDisableLogging=false

  # Ensure user can see the prompt.
  if $isLoggingEnabled; then
    disableLogging
    weDisableLogging=true
  fi

  # Stores user input
  local input=""

  # Number of retries before failing.
  local counter=4

  # User input prompt
  if [[ "$2" == "" ]]; then
    local prompt="> "
  else
    local prompt=$2": "
  fi

  # Keep asking for user input until it is valid
  # or until the max number of retries.
  while [ $counter -gt 0 ]; do
    let COUNT=COUNT-1
    
    echo -n $prompt
    read input

    # If the input is valid, return it
    if [[ "$input" != "" ]]; then
      if [[ "$1" == "" ]]; then
        # Echo the output so it can be captured using $()
        echo $input
      else
        # Stores the output in the variable specified.
        eval $1="'$input'"
      fi

      # Turn back on logging if we turned it off.
      if $weDisableLogging; then
        enableLogging
      fi

      # Return success.
      return 0
    fi
  done

  # Turn back on logging if we turned it off.
  if $weDisableLogging; then
    enableLogging
  fi

  # User input was not valid the max number of
  # times, so exit script with error.
  end "User input was invalid."
}

# Get user input, but hide the input.
function getUserInputHidden {
  # Ensure user can see the prompt.
  if $isLoggingEnabled; then
    #TODO: Turn off logging.
    end "Script logging is on, cannot prompt user."
  fi

  # Stores user input
  local input=""

  # Number of retries before failing.
  local counter=4

  # User input prompt
  if [[ "$2" == "" ]]; then
    local prompt="> "
  else
    local prompt=$2": "
  fi

  # Keep asking for user input until it is valid
  # or until the max number of retries.
  while [ $counter -gt 0 ]; do
    let COUNT=COUNT-1
    
    echo -n $prompt
    stty_original=`stty -g`
    stty -echo
    read input
    stty $stty_original
    echo

    # If the input is valid, return it
    if [[ "$input" != "" ]]; then
      if [[ "$1" == "" ]]; then
        # Echo the output so it can be captured using $()
        echo $input
      else
        # Stores the output in the variable specified.
        eval $1="'$input'"
      fi

      # Return success.
      return 0
    fi
  done

  # User input was not valid the max number of
  # times, so exit script with error.
  end "User input was invalid."
}





# ----------------------------------------- #
# End Script Methods
# ----------------------------------------- #

# Exit the script.
function end {
  msg=$1

  # Clear any private information.
  vpnUsername=""
  vpnPassword=""

  if [[ "$msg" != "" ]]; then
    echo "Error:  "$msg
    exit 1
  else
    exit 0
  fi
}


# ----------------------------------------- #
# Install Methods
# ----------------------------------------- #

# Install and start ART.
function requireArt {
  if [ ! -d "$scriptRootDirectory" ]; then

    # Ensure we have root permission
    requireRootPermission    

    # Ensure git is installed.
    installPackage "git"

    # Download ART scripts and files and setup permissions.
    git clone https://github.com/ssmereka/art.git $scriptRootDirectory
    sudo chmod +x $vpnMonitorScript
    sudo chmod +x $artScript

    # Remove this script and run start.
    #"."$artScript -z $curScriptDir"/"$artScriptName &
    end
  fi
}

# Update and start ART.
function updateArt {
  if [ ! -d "$scriptRootDirectory" ]; then
    
    # Ensure git is installed.
    gitLocation=`which git`
    if [[ "$gitLocation" == "" ]]; then
      sudo apt-get install git -y --force-yes
    fi

    # Create an update script in a temp location.
    # The update script will update and start ART,
    # then remove itself.
    tmpScript="/tmp/art_tmp.sh"
    echo "sleep 5" > $tmpScript
    echo "git pull https://github.com/ssmereka/art.git $scriptRootDirectory" >> $tmpScript
    echo ".$artScript -z $curScriptDir\"/\"$artScriptName &" >> $tmpScript
    echo "exit" >> $tmpScript
    "."$tmpScript &
    end
  fi
}

# Install a package if it is not already installed.
function installPackage() {
  package=$1

  if [[ "$package" == "" ]]; then
    end "Cannot install an undefined package."
  fi

  # Check if the package is installed, if not install it.
  if [[ `which $package` == "" ]]; then

    # Ensure script has root permission.
    requireRootPermission

    # Update package manager if it hasn't been already.
    if ! $isPmUpdated; then
      printJob "Updating package manager"
      sudo apt-get update -y --force-yes
      isPmUpdated=true;
      printJobDone
    fi

    # Install the package.
    printJob "Installing "$package
    sudo apt-get install $package -y --force-yes
    printJobDone
  fi
}

# Install a package if it is not already installed.
function removePackage() {
  package=$1

  if [[ "$package" == "" ]]; then
    echo "Cannot uninstall an undefined package."
    return 1
  fi

  # Check if the package is installed, if so uninstall it.
  if [[ `which $package` == "" ]]; then

    # Ensure script has root permission.
    requireRootPermission

    printJob "Uninstalling "$package
    sudo apt-get --perge remove $package -y --force-yes
    printJobDone
  fi
}


# ----------------------------------------- #
# Log Methods
# ----------------------------------------- #

# Start logging output of script to the log file.
# Creates a new log file if needed.
function enableLogging {
  if [ ! -f $logFile ]; then
    echo -e "----------------------------------------" > $logFile
    echo -e "Log Start" >> $logFile
    echo -e "----------------------------------------\n" >> $logFile
  fi
  exec 3>&1 4>&2 1>>${logFile} 2>&1
  isLoggingEnabled=true
}

# Stops logging output of script to the log file.
function disableLogging {
  exec 1>&3 2>&4
  isLoggingEnabled=false
}

# Removes the log file if it exists.
function deleteLogFile {
  if [ -f $logFile ]; then
    rm $logFile
  fi
}


# ----------------------------------------- #
# Print Methods
# ----------------------------------------- #

# Print help menu.
function printHelp {
  echo -e "usage: \t art.sh [options] \n"
  
  echo -e "options:"
  echo -e "  -k \t kill   \t Stop the vpn and monitoring service."  
  #echo -e "  -l \t list   \t List the available vpns to connect to."
  echo -e "  -s \t start  \t Start the vpn and monitoring service."
  #echo -e "  -u \t update \t Update the current list of vpns."

  # Hidden flags.
  if $debug; then
    echo -e "  -d \t debug  \t Toggle on debug mode to display extra logs."
    echo -e "  -z \t z      \t Finish the install."
  fi

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
  
  # If the job name was not specified, use the current job
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

# Print the log file to the console.
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

# Tail the log file.
function tailLogs {
  tail -f $logFile
}


# ----------------------------------------- #
# Root Methods
# ----------------------------------------- #

# Ensure the user is root before continuing.
function requireRootPermission {
  if [[ $UID != 0 ]]; then
    echo -e "\nPermission Denied:  Try again using sudo. \n"
    echo -e "\t sudo $0 $* \n"
    end
  else
    isRoot=true
  fi
}

# ----------------------------------------- #
# Torguard Methods
# ----------------------------------------- #

# Update the openvpn config files for torguard.
function updateTorguardVpnConfigs {
  # Ensure user has root permission.
  requireRootPermission

  # Ensure unzip is installed.
  installPackage "unzip"

  # Ensure there are credentials for openvpn configs.
  requireAuthFile

  printJob "Updating "$provider" openvpn config files."
  
  if [ -f $openvpnConfigFolder".zip" ]; then
    echo "Removing current "$provider" config zip archive."
    sudo rm $openvpnConfigFolder".zip"
  fi
  
  if [ -f $openvpnConfigFolder ]; then
    echo "Removing current "$provider" openvpn config files and folder."
    sudo rm -rf $openvpnConfigFolder
  fi

  echo "Downloading new "$provider" openvpn config files."
  wget "https://torguard.net/downloads/"$openvpnConfigFolder".zip"
  unzip $openvpnConfigFolder".zip"
  
  echo "Adding authentication to openvpn config files."
  cd $openvpnConfigFolder
  sed -i -e "s/auth-user-pass/auth-user-pass "$authFile"/" *.ovpn
  cd $scriptRootDirectory

  printJobDone
}


# ----------------------------------------- #
# VPN Methods
# ----------------------------------------- #

# Ensure openvpn and its config files are installed.
function requireOpenVpn {
  installPackage "openvpn"

  # Ensure openvpn configs are downloaded.
  if [[ ! -d "$openvpnConfigFolder" ]]; then
    updateVpnConfigs
  fi
}

# Update the openvpn config files by removing
# the old configs, if they exist, and downloading
# the new ones.
function updateVpnConfigs {
  if [[ "$vpnProvider" == "$torguard" ]]; then
    updateTorguardVpnConfigs
    return 0
  fi

  end "Cannot update vpn config files for unsupported provider."
}

# Start a monitor that will ensure the VPN is up and running.
function startVpnMonitor {
  # Require root permission for vpn monitor script.
  requireRootPermission

  # 

  # Require openvpn to be installed and configured.
  requireOpenVpn

  printJob "Starting vpn monitor"
  $vpnMonitorScript $openVpnConfigFile $ip $openvpnLogFile $debug &
  printJobDone
}

# Stop the vpn and the monitor.
function stopVpnMonitor {
  # Kill the openvpn monitor  
  printJob "Killing openvpn monitor"
  killall $vpnmonScriptName
  printJobDone
  
  # Kill the openvpn server.
  openvpnPid=`pgrep openvpn`
  if [[ "$openvpnPid" != "" ]]; then
    printJob "Killing openvpn"
    sudo kill -9 `pgrep openvpn`
    printJobDone
  fi
}


# ----------------------------------------- #
# Script Logic
# ----------------------------------------- #

# Possible script flags.
helpFlag=false
killFlag=false
printFlag=false
startFlag=false
updateFlag=false
listFlag=false
tailFlag=false
isHandled=false

# Handle script flags.
for var in "$@"
do
  case "$var" in
    -d | -debug | [debug])
      debug=true
      ;;

    -h | -help | [help])
      helpFlag=true
      ;;

    -k | -kill | [kill])
      isHandled=true
      killFlag=true

      # The following flags cannot be 
      # executed with a kill command
      startFlag=false
      ;;
 
    -l | -list | [list])
      isHandled=true
      listFlag=true
      ;;
   
    -p | -print | [print])
      isHandled=true
      printFlag=true
      ;;

    -s | -start | [start])
      isHandled=true
      startFlag=true
      
      # The following flags cannot be 
      # executed with a kill command
      killFlag=false
      ;;
    
    -t | -tail | [tail])
      isHandled=true
      tailFlag=true
      ;;

    -u | -update | [update])
      isHandled=true
      updateFlag=true
      ;;
  esac
done

# If no options are specified, print the help menu.
if $helpFlag || ! $isHandled; then
  printHelp
  end
fi

# Ensure ART is installed
requireArt

# Start logging to the log file.
startLogging

# Update the script and its dependancies.
if $updateFlag; then
  #update
fi

# Start the vpn and vpn monitor.
if $startFlag; then
  startVpnMonitor
fi

# Stop the vpn and vpn monitor.
if $killFlag; then
  stopVpnMonitor
fi

# List the available vpns.
if $listFlag; then
  end
fi

# Print the log file.
if $printFlag; then
  printLogs
fi

# Tail the log file.
if $tailFlag; then
  tailLogs
fi

# End the script
end