Anonymous Raspberry TORte
=========================

![Anonymous Raspberry TORte](http://i.imgur.com/un4L5FZ.png)  


Turns a raspberry pi into a secure and anonymous torrent box with a single command.

**Current Status:** In Development nearing Alpha

# How?
ART creates a Virtual Private Network (VPN) that encrypts all of your data.  Then ensures the VPN is always up and running, taking action if it fails.  A VPN requires a provider, aka something to connect to.  ART has been preconfigured to work with the popular and secure [providers](https://github.com/ssmereka/art/wiki/VPN-Providers).

# Ok, Lets do it!

  1. Get your raspberry pi setup and running a stock image of debian wheezy.
  2. Download this script using wget.

      `wget https://raw.githubusercontent.com/ssmereka/art/master/art`

  3. Give the script permissions to run and run it.

      `sudo chmod +x art && sudo ./art -s`
      
      
# Usage
Once installed, art can be used from anywhere by issuing the *art* command.

![ART Usage](http://i.imgur.com/KCyLm6C.png?2) 

## Start
You can start the vpn and vpn monitor from anywhere using the start command.  If the vpn stops then the vpn monitor will ensure the vpn is restarted.

`sudo art -s`

## Stop
If you need to turn off the vpn and the vpn monitoring simply issue the kill command.

`sudo art -k`

# Add Torrents
[Deluge](http://deluge-torrent.org/) is a torrent client installed by ART to your raspberry pi.  You can add torrents to Deluge remotely from another computer using one of the three methods below.

  * [Web Client](https://github.com/ssmereka/art/wiki/Guides#webclient) - Easiest way to use Deluge.
  * [Chrome Plugin](https://github.com/ssmereka/art/wiki/Guides#chromeplugin) - Send magnetic links and torrent files directly to Deluge.
  * [Desktop Client](https://github.com/ssmereka/art/wiki/Guides#desktopclient) - Includes all the Deluge features and a little faster to use.

# [FAQ](https://github.com/ssmereka/art/wiki/FAQ)
