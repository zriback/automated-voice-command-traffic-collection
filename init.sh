#!/bin/bash

sudo apt-get -y update

# Install and configure access point software
sudo apt-get -y install hostapd
sudo cp ./etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf

sudo rfkill unblock wlan
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

# Set up network bridge
sudo cp ./etc/systemd/network/bridge-br0.netdev /etc/systemd/network/bridge-br0.netdev
sudo cp ./etc/systemd/network/br0-member-eth0.network /etc/systemd/network/br0-member-eth0.network
sudo cp ./etc/dhcpcd.conf /etc/dhcpcd.conf

sudo systemctl enable systemd-networkd

# Install flite software and download extra voices
sudo apt-get -y install flite

mkdir -p voices
FLITE_VOICES=http://www.festvox.org/flite/packed/flite-2.0/voices/
wget $FLITE_VOICES/cmu_us_aew.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_ahw.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_aup.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_awb.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_axb.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_bdl.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_clb.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_eey.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_fem.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_gka.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_jmk.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_ksp.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_ljm.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_rms.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_rxr.flitevox -P ./voices/
wget $FLITE_VOICES/cmu_us_slt.flitevox -P ./voices/

# Install other needed packages
sudo apt-get -y install pavucontrol tcpdump sox

# Prompt for reboot of the system
read -n 1 -s -r -p "\nSetup has finished! Press any key to reboot..."
sudo systemctl reboot
