Anonymous Raspberry TORte
=========================

Turns a raspberry pi into a secure and anonymous torrent box.

<p align="center">
  <img src="http://i.imgur.com/pTzupF0.jpg?1" alt="Anonymous Raspberry TORte"/>
</p>


This script will setup your pi to use a vpn for all traffic ensuring your anonymity.  It will also monitor your IP address to ensure the vpn is working correctly.

**Current Status:** In Development.

# Setup

  1. Get your raspberry pi setup and running a stock image of debian wheezy.
  2. Download this script using wget.

      `wget https://raw.githubusercontent.com/ssmereka/art/master/start.sh`
      
  3. Give the script permissions to run and run it.

      `sudo chmod +x start.sh && ./start.sh -s`
      
# Stop
If you need to turn off the vpn and the vpn monitoring simply issue the kill command. \\
`sudo ./start -k`

# Usage



