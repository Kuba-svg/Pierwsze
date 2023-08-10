!#/bin/bash
systemctl stop NetworkManager.service
systemctl disable NetworkManager.service
systemctl disable systemd-networkd
systemctl stop systemd-networkd
ifconfig eth0 down
ip link set eth0 master br0
ip addr add 192.168.10.5/16 dev br0 brd 192.168.255.255
ip link set up eth0
ip link set up br0
systemctl enable systemd-networkd
systemctl start systemd-networkd

#### Alternatively ####

# file is /etc/systemd/network/br.netdev

# [NetDev]
# Name=br0
# Kind=bridge

# file is 1-br0-bind.network

# [Match]
# Name=eno1

# [Network]
# Bridge=br0

# file is /etc/systemd/network/2-br0-dhcp.network

# [Match]
# Name=br0

# [Network]
# DHCP=ipv4

# systemctl enable systemd-networkd

