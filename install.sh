#!/bin/bash	

if [[ $# != 2 ]]; then
	echo "usage: $0 [MicroVM IP] [TAP IP]"
	exit -1
fi

microVM_IP=$1
tap_IP=$2

./startup/busybox-x86_64 ifconfig eth0 $microVM_IP netmask 255.255.255.0 
./startup/busybox-x86_64 ifconfig eth0 up
./startup/busybox-x86_64 ifconfig lo up
./startup/busybox-x86_64 route add default gw $tap_IP

#manik start
#./startup/busybox-x86_64 ip addr add $microVM_IP/24 dev eth0
#./startup/busybox-x86_64 ip link set eth0 up
#./startup/busybox-x86_64 ip route add default via $tap_IP dev eth0
#manik end

export PATH=$PATH:/usr/local/sbin/ &&
export PATH=$PATH:/usr/sbin/ &&
export PATH=$PATH:/sbin &&
apt-get update -y &&
apt-get upgrade -y  &&
dpkg --configure -a  &&

apt-get install font-manager -y &&
apt-get install dbus-x11 -y &&
apt install adwaita-icon-theme-full &&
apt install wget -y &&
apt install strace -y &&
apt install net-tools -y &&
apt install wmctrl -y

#gedit
apt install gedit -y 

#libre
apt install libreoffice -y && apt install libcanberra-gtk-module libcanberra-gtk3-module -y

#evince
apt install evince -y 

#eog
apt install eog -y

#firefox
apt install firefox -y

#thunderbird
apt install thunderbird -y && apt-get install libotr5 -y

#chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
apt install ./google-chrome-stable_current_amd64.deb -y


#slack
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb &&
apt install ./slack-desktop-*.deb -y
apt install libappindicator1
apt install libdbusmenu-glib4:amd64 

apt-get install -f 
apt-get --fix-broken install


