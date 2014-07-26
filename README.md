Anonymous Raspberry TORte
=========================

![Anonymous Raspberry TORte](http://i.imgur.com/un4L5FZ.png)  


Turns a raspberry pi into a secure and anonymous torrent box with a single command.

**Current Status:** In Development nearing Alpha

# How?
ART creates a VPN that encrypts all of your data.  Then ART ensures this VPN is always up and running, taking action if the vpn fails.  A VPN requires a VPN provider such as Torguard.  ART is preconfigured to work with the popular and secure providers.

# Ok, Lets do it!

  1. Get your raspberry pi setup and running a stock image of debian wheezy.
  2. Download this script using wget.

      `wget https://raw.githubusercontent.com/ssmereka/art/master/art`

  3. Give the script permissions to run and run it.

      `sudo chmod +x art && sudo ./art -s`
      
      
# Usage
Once installed, art can be used from anywhere by issuing the *art* command.

![ART Usage](http://i.imgur.com/KCyLm6C.png?2) 

## Stop
If you need to turn off the vpn and the vpn monitoring simply issue the kill command.

`sudo art -k`

# Compatible VPNs:
ART is preconfigured to work with the following vpn service providers:

  * [Torguard](https://torguard.net/)


