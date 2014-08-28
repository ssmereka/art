Anonymous Raspberry TORte
=========================

![Anonymous Raspberry TORte](http://i.imgur.com/un4L5FZ.png)  


Turns a raspberry pi into a secure and anonymous torrent box with a single command.

**Current Status:** In Development nearing Alpha

# How?
ART creates a Virtual Private Network (VPN) that encrypts all of your data.  Then ensures the VPN is always up and running, taking action if it fails.  A VPN requires a provider, aka something to connect to.  ART has been preconfigured to work with the popular and secure [providers](#vpnProviders).

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

# Torrent Client
A torrent client is required to actually download torrent files.  There are many to choose from, however ART will automatically install and configure the [Deluge](http://deluge-torrent.org/) client for you.  Once ART is installed you will be able to add torrent files to Deluge via a website, desktop client, and/or a chrome plugin.

## Web Client
The easiest way to use Deluge is the web client because you can add torrents from anywhere.

1. Enter your pi's IP address into any browser.  `http://192.168.1.102:58846`
2. Login using your deluge password.  (The default password is:  deluge)
3. Use the connection manager to add your pi as a host.
4. Finally connect to your pi.

## Chrome Plugin
Want to send all magnetic links and torrent files you click on to your pi?  Install the [Deluge Siphon](https://chrome.google.com/webstore/detail/delugesiphon/gabdloknkpdefdpkkibplcfnkngbidim?hl=en) plugin.

## Desktop Client
Rather than using a website you can also use the [Deluge Desktop Client](dev.deluge-torrent.org/wiki/Download).  The desktop client is a little easier to use and has more functionality than the web client.  Once the desktop client is installed you can connect to your pi by adding a new host.  

1. Add a host using the username/password you provided to ART during install.  ![Add Host](http://i.imgur.com/Mb2kfQV.jpg?1)
2. Connect to the host using the connection manager.  ![Connection Manager](http://i.imgur.com/49h6OYM.jpg)

<a name="vpnProviders" />
# Compatible VPNs:
ART is preconfigured to work with the following vpn service providers:

  * [Torguard](https://torguard.net/)


