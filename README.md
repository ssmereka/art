Anonymous Raspberry TORte
=========================

<p align="center">
  <img src="http://i.imgur.com/pTzupF0.jpg?1" alt="Anonymous Raspberry TORte"/>
</p>


Turns a raspberry pi into a secure and anonymous torrent box with just one command.  ART will setup your pi to use a vpn for all traffic ensuring your anonymity.  It will also monitor your IP address to ensure the vpn is working correctly at all times.

**Current Status:** In Development nearing Alpha

# Compatible VPNs:
ART is preconfigured to work with the following vpn service providers:

  * [Torguard](https://torguard.net/)

# Setup

  1. Get your raspberry pi setup and running a stock image of debian wheezy.
  2. Download this script using wget.

      `wget https://raw.githubusercontent.com/ssmereka/art/master/art.sh`
      
      or something shorter
      
      `wget http://cli.gs/art.sh`
      
  3. Give the script permissions to run and run it.

      `sudo chmod +x art.sh && ./art.sh -s`
      
# Stop
If you need to turn off the vpn and the vpn monitoring simply issue the kill command. \\
`sudo ./art -k`



