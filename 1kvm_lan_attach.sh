!#/bin/bash
systemctl stop systemd-networkd
systemctl disable systemd-networkd
ip link set eth0 master br0
ip addr add 192.168.10.3/16 dev br0 brd 192.168.255.255 ## You can add any IP. It is just temporary and it will change for your LAN IP later.
ip link set up eth0 && ip link set up br0
systemctl enable systemd-networkd
systemctl start systemd-networkd


#### Alternatively create this files in followed directories. ####

# file is /etc/systemd/network/br.netdev

# [NetDev]
# Name=br0
# Kind=bridge

# file is 1-br0-bind.network

# [Match]
# Name=eth0

# [Network]
# Bridge=br0

# file is /etc/systemd/network/2-br0-dhcp.network

# [Match]
# Name=br0

# [Network]
# DHCP=ipv4

# systemctl enable systemd-networkd

# To go back to normal settings just switch on Network Manager
# systemctl start NetworkManager
# systemctl enable NetworkManager

