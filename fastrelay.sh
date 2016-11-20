#!/usr/bin/env bash
#===============================================================================================================================================
# (C) Copyright 2016 TorWorld (https://torworld.org) a project under the CryptoWorld Foundation (https://cryptoworld.is).
#
# Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================================================================================
# title            :FastRelay
# description      :This script will make it super easy to run a Tor Relay Node.
# author           :TorWorld A Project Under The CryptoWorld Foundation.
# contributors     :KsaRedFx, SPMedia, Lunar, NurdTurd, Codeusa
# date             :11-20-2016
# version          :0.0.5 Alpha
# os               :Debian/Ubuntu
# usage            :bash fastrelay.sh
# notes            :If you have any problems feel free to email us: security[at]torworld.org
#===============================================================================================================================================

# Checking if curl is installed
if [ ! -x /usr/bin/curl ]
then
    echo -e "\033[31mcurl Command Not Found\e[0m"
    echo -e "\033[34mInstalling curl, Please Wait...\e[0m"
    apt-get install curl
fi

# Get SHML (http://shml.xyz)
bash -c 'curl -SsL https://raw.githubusercontent.com/maxcdn/shml/latest/shml.sh -o shml.sh'
source ./shml.sh

# Checking if lsb_release is installed
if [ ! -x /usr/bin/lsb_release ]
then
    echo "$(fgc red "lsb_release command not found") $(fgc end)"
    echo "$(fgc blue "Installing lsb-release, Please Wait...") $(fgc end)"
    apt-get install lsb-release
fi

# Getting Codename of the OS
flavor=`lsb_release -cs`

# Define functions

# Yes or No question
function yesNo {
  read -p "$(fgc lightyellow "$1 ")$(a bold "")$(fgc lightcyan "(")$(fgc lightblue "Y")$(fgc lightcyan "/")$(fgc lightblue "N")$(fgc lightcyan ")")$(fgc end)"$(a end)" " REPLY
}
# User input question
function userInput {
  read -p "$(fgc lightyellow "$1: ")$(fgc end)" $2
}
# Three-Point Loader
function loader {
  echo $(fgc blue "$1...")$(fgc end)
}
# Getter status check
function getter {
  echo $(fgc blue "$1 ")$(a bold "")$(fgc lightcyan "[ ")$(fgc lightgreen "")$(icon check)$(fgc lightcyan " ]")$(fgc end)$(a end)$(fgc end)
}
# Notice message
function notice {
  echo $(fgc blue "$1")$(fgc end)
}

# Installing dependencies for Tor
yesNo "Do you want to fetch the core Tor dependencies?"
if [ "${REPLY,,}" == "y" ]; then
   echo deb http://deb.torproject.org/torproject.org $flavor main >> /etc/apt/sources.list.d/torproject.list
   echo deb-src http://deb.torproject.org/torproject.org $flavor main >> /etc/apt/sources.list.d/torproject.list
   gpg --keyserver keys.gnupg.net --recv 886DDD89
   gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
fi

# Updating / Upgrading System
yesNo "Do you wish to upgrade system packages?"
if [ "${REPLY,,}" == "y" ]; then
   apt-get update
   apt-get dist-upgrade
fi

# Installing Tor
yesNo "Do you wish to install Tor? $(fgc red "(Make sure you're 100% certain you want to do this)")$(fgc end)"
if [ "${REPLY,,}" == "y" ]; then
   apt-get install tor
   loader "Retrieving status of Tor"
   service tor status && getter "Retrieve status of Tor"
   loader "Stopping Tor service"
   service tor stop
   getter "Stop Tor service"
fi

# Customizing Tor RC file to suit your Relay
# Nickname for Relay
userInput "Enter your desired Relay nickname"  Name
echo "Nickname $Name" > /etc/tor/torrc

# DirPort for Relay
userInput "Enter your desired DirPort (example: 80, 9030)" DirPort
echo "DirPort $DirPort" >> /etc/tor/torrc

# ORPort for Relay
userInput "Enter your desired ORPort (example: 443, 9001)" ORPort
echo "ORPort $ORPort" >> /etc/tor/torrc

# Exit Policy for Relay
notice "By default we do not allow exit policies for Relays (So this content is static.)"
echo "Exitpolicy reject *:*" >> /etc/tor/torrc

# Contact Info for Relay
userInput "Enter your contact info for your Relay" Info
echo "ContactInfo $Info" >> /etc/tor/torrc

# Restarting Tor service
loader "Trying to restart the Tor service"
service tor restart && getter "Restart the Tor service"

# Installing TorARM
yesNo "Would you like to install Tor ARM to help monitor your Relay?"
if [ "${REPLY,,}" == "y" ]; then
   apt-get install tor-arm
   notice "Fixing the Tor RC to allow Tor ARM"
   echo "DisableDebuggerAttachment 0" >> /etc/tor/torrc
   echo $(fgc blue "To start TorARM just type: ")$(fgc lightyellow "arm")$(fgc end)
fi
rm -Rfv ./shml.sh