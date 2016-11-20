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
# contributors     :KsaRedFx, SPMedia, Lunar
# date             :10-28-2016
# version          :0.0.5 Alpha
# os               :Debian/Ubuntu
# usage            :bash fastrelay.sh
# notes            :If you have any problems feel free to email us: security[at]torworld.org
#===============================================================================================================================================

# Checking if lsb_release is Installed
if [ ! -x  /usr/bin/lsb_release ]
then
    echo -e "\033[31mLsb_release Command Not Found\e[0m"
    echo -e "\033[34mInstalling lsb-release, Please Wait...\e[0m"
    apt-get install lsb-release
fi

# Getting Codename of the OS
flavor=`lsb_release -cs`

# Installing dependencies for Tor
read -p "Do you want to fetch the core Tor dependencies? (Y/N)" REPLY
if [ "${REPLY,,}" == "y" ]; then
   echo deb http://deb.torproject.org/torproject.org $flavor main >> /etc/apt/sources.list.d/torproject.list
   echo deb-src http://deb.torproject.org/torproject.org $flavor main >> /etc/apt/sources.list.d/torproject.list
   gpg --keyserver keys.gnupg.net --recv 886DDD89
   gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
fi

# Updating / Upgrading System
read -p "Do you wish to upgrade system packages? (Y/N)" REPLY
if [ "${REPLY,,}" == "y" ]; then
   apt-get update
   apt-get dist-upgrade
fi

# Installing Tor
read -p "Do you wish to install Tor? (Make sure you're 100% certain you want to do this) (Y/N)" REPLY
if [ "${REPLY,,}" == "y" ]; then
   apt-get install tor
   echo "Getting status of Tor.."
   service tor status
   echo "Stopping Tor service..."
   service tor stop
fi

# Customizing Tor RC file to suit your Relay
# Nickname for Relay
read -p "Enter your desired Relay nickname: "  Name
echo "Nickname $Name" > /etc/tor/torrc

# DirPort for Relay
read -p "Enter your desired DirPort: (example: 80, 9030) " DirPort
echo "DirPort $DirPort" >> /etc/tor/torrc

# ORPort for Relay
read -p "Enter your desired ORPort: (example: 443, 9001) " ORPort
echo "ORPort $ORPort" >> /etc/tor/torrc

# Exit Policy for Relay
echo "By default we do not allow exit policies for Relays (So this content is static.)"
echo "Exitpolicy reject *:*" >> /etc/tor/torrc

# Contact Info for Relay
read -p "Enter your contact info for your Relay: " Info
echo "ContactInfo $Info" >> /etc/tor/torrc

# Restarting Tor service
echo "Restarting the Tor service..."
service tor restart

# Installing TorARM
read -p "Would you like to install Tor ARM to help monitor your Relay? (Y/N)" REPLY
if [ "${REPLY,,}" == "y" ]; then
   apt-get install tor-arm
   echo "Fixing the Tor RC to allow Tor ARM"
   echo "DisableDebuggerAttachment 0" >> /etc/tor/torrc
   echo "To start TorARM just type: "arm""
fi
