#! /bin/bash 

tap_name="vmtap1"
tap_IP="192.168.241.1"
tap_MAC="AA:FC:00:00:00:00"
microVM_IP="192.168.241.2"

namespace="ns1"
ns_veth_name="veth1"
ns_veth_ip="193.168.1.1"
gbl_veth_name="veth2"
gbl_veth_ip="193.168.1.2"
display_IP="172.27.28.252"

  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 [server|client] <app-name> [filename (arg)]"
    exit -1
  else
      app_name=$2
      file_name=$3
  fi


function network_setup()
{
    xhost +
    #delete any previously created interfaces
    if [[ -f /run/netns/$namespace ]];then
        sudo ip netns delete $namespace
    fi
    if [[ -e /sys/class/net/$gbl_veth_name ]];then
        sudo ip link del $gbl_veth_name
    fi
    #manik start
    sudo ip link del $tap_name
    sudo iptables -F
    sudo sh -c "echo 0 > /proc/sys/net/ipv4/ip_forward" # usually the default
    
    sudo ip tuntap add $tap_name mode tap
    sudo ip addr add $tap_IP/24 dev $tap_name
    sudo ip link set $tap_name up
    sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
    sudo iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
    sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -i $tap_name -o eno1 -j ACCEPT
    #manik end

    #sudo ss -K dst $ns_veth_ip > /dev/null

    #msudo ip netns add $namespace
    #msudo ip netns exec $namespace ip tuntap add name $tap_name mode tap
    #msudo ip netns exec $namespace ip addr add $tap_IP/24 dev $tap_name
    #msudo ip netns exec $namespace ip link set $tap_name up
    #msudo ip netns exec $namespace ip link set lo up


    # create the veth pair inside the namespace
    #msudo ip netns exec $namespace ip link add $gbl_veth_name type veth peer name $ns_veth_name
    # move veth2 to the global host namespace
    #msudo ip netns exec $namespace ip link set $gbl_veth_name netns 1

    #msudo ip netns exec $namespace ip addr add $ns_veth_ip/24 dev $ns_veth_name
    #msudo ip netns exec $namespace ip link set dev $ns_veth_name up

    #msudo ip addr add $gbl_veth_ip/24 dev $gbl_veth_name
    #msudo ip link set dev $gbl_veth_name up

    # designate the outer end as default gateway for packets leaving the namespace
    #msudo ip netns exec $namespace ip route add default via $gbl_veth_ip
    # for packets that leave the namespace and have the source IP address of the
    # original guest, rewrite the source address to clone address 192.168.0.3
    #msudo ip netns exec $namespace iptables -t nat -A POSTROUTING -o $ns_veth_name \
    #m-s $microVM_IP -j SNAT --to $ns_veth_ip

    # do the reverse operation; rewrites the destination address of packets
    # heading towards the clone address to 192.168.241.2
    #msudo ip netns exec $namespace iptables -t nat -A PREROUTING -i $ns_veth_name \
    #m-d $ns_veth_ip -j DNAT --to $microVM_IP

    # (adds a route on the host for the clone address)
    #sudo ip route add $ns_veth_ip via $gbl_veth_ip

    #msudo iptables -A FORWARD -i eno1 -o $gbl_veth_name -j ACCEPT
    #msudo iptables -A FORWARD -o eno1 -i $gbl_veth_name -j ACCEPT

    echo "Network setup complete"  
}

function start_apiserver()
{
    sudo rm -f /tmp/firecracker.socket
    echo "starting server"
    sudo /home/manik/fcproject/release-v1.2.0-x86_64/firecracker-v1.2.0-x86_64 --api-sock /tmp/firecracker.socket

    #cleanup
    #sudo rm -f /tmp/$namespace.socket
    #if [[ -f /run/netns/$namespace ]];then
    #    sudo ip netns delete $namespace
    #fi
    #if [[ -e /sys/class/net/$gbl_veth_name ]];then
    #    sudo ip link del $gbl_veth_name
    #fi
    #sudo ss -K dst $ns_veth_ip > /dev/null
}
if [[ "$1" == "client" ]]; then
  sudo ./microvm_start.sh $namespace $display_IP $microVM_IP $tap_name $tap_IP $tap_MAC $app_name $file_name   

elif [[ "$1" == "server" ]]; then
  network_setup 
  start_apiserver
fi
exit



