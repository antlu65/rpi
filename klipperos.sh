﻿#!/bin/bash
echo -e "\n ---***--- Klipper Raspbian Setup\n"

# Configure Password.
echo -e " -*- Configure Password ... "
    user=pi
    pass=IMnotBNcrE8ive
    echo "$user:$pass" | sudo chpasswd
echo -e " --- OK\n"

# Configure Timezone.
echo -e " -*- Configure Timezone ... "
    sudo rm -f /etc/localtime
    sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo -e " --- OK\n"

# Configure Locale.
echo -e " -*- Configure Locale ... "
    touch locale
    cat <<- EOF > locale
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
EOF
    sudo mv -f locale /etc/default/locale
    touch locale.gen
    cat <<- EOF > locale.gen
en_US.UTF-8
EOF
    sudo mv -f locale.gen /etc/locale.gen
echo -e " --- OK\n"

# Configure Keyboard.
echo -e " -*- Configure Keyboard ... "
    kbconfig="keyboard"
    touch $kbconfig
    cat <<- EOF > $kbconfig
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
EOF
    sudo mv -f $kbconfig /etc/default/$kbconfig
echo -e " --- OK\n"

# Configure Terminal.
echo -e " -*- Configure Terminal ... "
    tconfig=override.conf
    rootusername=pi
    cat <<-EOF > $tconfig
[Service]
ExecStart=
ExecStart=/sbin/agetty --noissue --autologin $rootusername %I $TERM
EOF
    sudo mv -f $tconfig /etc/systemd/system/getty@tty1.service.d/$tconfig
echo -e " --- OK\n"

# Enable I2c, Disable Bluetooth, Audio, Graphics
echo -e " -*- Enable Two Wire Interface, Disable Bluetooth, Audio, Graphics ... "
  	cat <<-EOF > config.txt
[all]
dtparam=i2c_arm=on
dtoverlay=disable-bt
EOF
  	sudo mv -f config.txt /boot/config.txt
echo -e " --- OK\n"

# Enable SSH.
echo -e " -*- Enable ssh ... "
    sudo systemctl enable ssh
    sudo systemctl start ssh
echo -e " --- OK\n"

# Setup Wifi.
echo -e " -*- Setup Wifi ... "
    sudo apt install net-tools wireless-tools wpasupplicant -y -qq
    network="AutoCoreNet"
    netpass="ColonialHeavy3298671"
    netconfig="wpa_supplicant.conf"	
    cat <<- EOF > $netconfig
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US
EOF
    wpa_passphrase "$network" "$netpass" >> $netconfig
    sudo mv -f $netconfig /etc/wpa_supplicant/$netconfig
    rfkill unblock wifi
    sudo ifconfig wlan0 up
    sudo dhclient wlan0 &
echo -e " --- OK\n"

# Upgrade Default Packages.
echo -e " -*- Upgrade Default Packages ... "
    sudo apt update -qq
    sudo apt upgrade -y -qq
echo -e " --- OK\n"

# Remove Auto-Update Service.
echo -e " -*- Remove Auto-Update Service ... "
    sudo systemctl --now disable apt-daily.timer apt-daily-upgrade.timer
    sudo systemctl --now disable apt-daily apt-daily-upgrade
    sudo systemctl --now kill apt-daily apt-daily-upgrade
    sudo systemctl daemon-reload
    sleep 3
    sudo rm /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock*
    sleep 3
    sudo dpkg --configure -a
    sleep 3
echo -e " --- OK\n"

# Cleanup.
echo -e " -*- Cleanup ... "
    #sudo apt remove raspi-config -y -qq
    sudo apt autoremove -y -qq
    rm raspios.sh
echo -e " --- OK\n"

# Reboot.
echo -e " ---***--- Setup Complete. Rebooting ... "
sudo docker ps
sleep 5
sudo shutdown -r now