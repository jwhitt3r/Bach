#!/system/bin/sh

prevconfig=$(getprop sys.usb.config)
if [ "${prevconfig}" != "${prevconfig#rndis}" ] ; then
	echo 'Is tethering already active?' >&2
	exit 1
fi

echo "${prevconfig}" > /cache/usb_tether_prevconfig
setprop sys.usb.config 'rndis,adb'
until [ "$(getprop sys.usb.state)" = 'rndis,adb' ] ; do sleep 1 ; done

ip rule add from all lookup main
ip addr flush dev rndis0
ip addr add 172.31.1.1/24 dev rndis0
ip link set rndis0 up
iptables -t nat -I POSTROUTING 1 -o rndis0 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward
dnsmasq --pid-file=/cache/usb_tether_dnsmasq.pid --interface=rndis0 --bind-interfaces --bogus-priv --filterwin2k --no-resolv --domain-needed --server=8.8.8.8 --server=8.8.4.4 --cache-size=1000 --dhcp-range=172.31.1.2,172.31.1.253,255.255.255.0,172.31.1.255 --dhcp-lease-max=253 --dhcp-authoritative --dhcp-leasefile=/cache/usb_tether_dnsmasq.leases < /dev/null
