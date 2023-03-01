#! /bin/bash


function do_launch_app()
{
    file=${2//_/.}  
    case $1 in
        chrome)     
            google-chrome --no-sandbox 
            ;;
        eog)
            eog $file
            ;;
        evince)
            evince $file
            ;;      
        firefox)
            firefox 
            ;;
        gedit)
            gedit $file
            ;;
        libreoffice)
            libreoffice --norestore --writer $file
            ;;
        slack)
            slack 
            ;;
        thunderbird)
            thunderbird 
            ;;      
        calc)
            ../../gtk
            ;;
    esac
}

 display_IP=$1 
 microVM_IP=${2//_/.}
 tap_IP=${3//_/.}
 date=$4
 time=$5
 app_name=$6
 file_name=`echo $7 | sed 's/\(.*\)_/\1./'`



#----------------------in-memory filesystem ---------------
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
mount -t tmpfs none /tmp

#required while installing packages
 mkdir /dev/pts
 mount -t devpts devpts /dev/pts 

mkdir /dev/fd
chmod 777 /dev/fd

mkdir /dev/shm
chmod 777 /dev/shm


./startup/guest_load_entropy 10000 > /dev/null


#----------------------environment
export DISPLAY=${display_IP//_/.}:0.0
date -s "$date $time" > /dev/null

#### To supress GUI APP warning https://bugzilla.redhat.com/show_bug.cgi?id=1056820
export NO_AT_BRIDGE=1

#manik start
#./startup/busybox-x86_64 ip addr add $microVM_IP/24 dev eth0
#./startup/busybox-x86_64 ip link set eth0 up
#./startup/busybox-x86_64 ip route add default via $tap_IP dev eth0

./startup/busybox-x86_64 ifconfig eth0 $microVM_IP netmask 255.255.255.0 
./startup/busybox-x86_64 ifconfig eth0 up
./startup/busybox-x86_64 ifconfig lo up
./startup/busybox-x86_64 route add default gw $tap_IP
#manik end
#ifconfig eth0 $microVM_IP netmask 255.255.255.0 broadcast 192.168.241.255
#ifconfig eth0 up
#ifconfig lo up
#route add default gw $tap_IP

#echo "--------------LAUNCHING APP-------------------------"
if [[ ! -z $file_name && $file_name == "bash" ]]; then
	#echo "Hi there $(pwd)"
	/bin/bash
else	
	case $file_name in
    bash)
        /bin/bash
        ;;    
    *)
        do_launch_app $app_name $file_name
        ;;        
	esac
fi

exit


