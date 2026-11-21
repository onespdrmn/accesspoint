modprobe 88x2bu

ifconfig wlx1cbfce1fb5fe down
iwconfig wlx1cbfce1fb5fe mode monitor

ifconfig wlp3s0 down
iwconfig wlp3s0 mode monitor

ifconfig wlx1cbfcef20a59 down
iwconfig wlx1cbfcef20a59 mode monitor

#enable wifi
hostapd hostapd-5G.conf &
hostapd hostapd-2G.conf &
hostapd hostapd-5G-2.conf &

sleep 5

dhclient eno1

ifconfig wlx1cbfce1fb5fe up 192.168.1.1 netmask 255.255.255.0
#route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1

ifconfig wlp3s0 up 192.168.2.1 netmask 255.255.255.0
#route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.2.1

ifconfig wlx1cbfcef20a59 192.168.3.1 netmask 255.255.255.0
#route add -net 192.168.3.0 netmask 255.255.255.0 gw 192.168.3.1

#setup NAT
iptables --table nat --append POSTROUTING --out-interface eno1 -j MASQUERADE
iptables --append FORWARD --in-interface wlx1cbfce1fb5fe -j ACCEPT
iptables --append FORWARD --in-interface wlp3s0 -j ACCEPT

#set up logging chain
iptables -N LOGGING

#ports to always ssh
/sbin/iptables -A INPUT -i wlp3s0 -p tcp --destination-port 2222 -j ACCEPT
/sbin/iptables -A INPUT -i wlp3s0 -p tcp --source-port 2222 -j ACCEPT
/sbin/iptables -A INPUT -i wlx1cbfce1fb5fe -p tcp --destination-port 2222 -j ACCEPT
/sbin/iptables -A INPUT -i wlx1cbfce1fb5fe -p tcp --source-port 2222 -j ACCEPT
/sbin/iptables -A INPUT -i eno1 -p tcp --destination-port 2222 -j ACCEPT
/sbin/iptables -A INPUT -i eno1 -p tcp --source-port 2222 -j ACCEPT

#some other ports to allow
/sbin/iptables -A INPUT -i wlp3s0 -p udp --destination-port 53   -j ACCEPT
/sbin/iptables -A INPUT -i wlp3s0 -p udp --source-port 53   -j ACCEPT
/sbin/iptables -A INPUT -i wlx1cbfce1fb5fe -p udp --destination-port 53   -j ACCEPT
/sbin/iptables -A INPUT -i wlx1cbfce1fb5fe -p udp --source-port 53   -j ACCEPT

/sbin/iptables -A INPUT -i wlx1cbfce1fb5fe -p tcp --destination-port 15600 -j ACCEPT
/sbin/iptables -A INPUT -i wlp3s0 -p tcp --destination-port 15600 -j ACCEPT

#ports to block on WAN interface
/sbin/iptables -A INPUT -i eno1 -p udp --destination-port 5353  -j DROP 
/sbin/iptables -A INPUT -i eno1 -p udp --destination-port 57646 -j DROP 
/sbin/iptables -A INPUT -i eno1 -p udp --destination-port 35291 -j DROP 
/sbin/iptables -A INPUT -i eno1 -p tcp --destination-port 53    -j DROP 
#/sbin/iptables -A INPUT -i eno1 -p tcp --destination-port 2222  -j DROP 
/sbin/iptables -A INPUT -i eno1 -p tcp --destination-port 6379  -j DROP 
/sbin/iptables -A INPUT -i eno1 -p tcp --destination-port 56411 -j DROP 
/sbin/iptables -A INPUT -i eno1 -p tcp --destination-port 49344 -j DROP 
/sbin/iptables -A OUTPUT --source 73.133.8.178 --destination 224.0.0.5  -j DROP

#disable ipv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

#stateful firewall (not working)
#/sbin/iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
#/sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
#/sbin/iptables -A INPUT -p tcp --dport 2222 -m conntrack --ctstate NEW -j ACCEPT 
#/sbin/iptables -A INPUT -p udp -m conntrack --ctstate NEW -j ACCEPT
#/sbin/iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT

#log and drop (not working yet)
#/sbin/iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
#/sbin/iptables -A INPUT -j LOGGING
#/sbin/iptables -A OUTPUT -j LOGGING
#/sbin/iptables -A LOGGING -j DROP  #don't uncomment this line!!!

#turn packet forwarding on
echo 1 > /proc/sys/net/ipv4/ip_forward

#dns cache on
/etc/init.d/dnsmasq restart

#turn on interfaces
ifconfig wlx1cbfce1fb5fe up
ifconfig wlx1cbfce1fb5fe 192.168.1.1 netmask 255.255.255.0

ifconfig wlp3s0 up
ifconfig wlp3s0 192.168.2.1 netmask 255.255.255.0

ifconfig wlx1cbfcef20a59 up
ifconfig wlx1cbfcef20a59 192.168.3.1 netmask 255.255.255.0

