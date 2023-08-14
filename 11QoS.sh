#!/bin/bash

# Nazwa interfejsu
IFACE="eth0"

# Prędkości łącza
DOWNLINK=20000 # 20mbit w kbps
UPLINK=10000   # 10mbit w kbps

# Czyszczenie istniejących reguł
tc qdisc del dev $IFACE root
tc qdisc del dev $IFACE ingress

# Ustawienie kolejek
tc qdisc add dev $IFACE root handle 1: htb default 20
tc qdisc add dev $IFACE ingress handle ffff:

# Ustawienie klasy bazowej
tc class add dev $IFACE parent 1: classid 1:1 htb rate ${DOWNLINK}kbit burst 15k
tc class add dev $IFACE parent 1: classid 1:2 htb rate ${UPLINK}kbit burst 15k

# Ustawienie klasy dla ruchu o wysokim priorytecie
tc class add dev $IFACE parent 1:1 classid 1:10 htb rate ${DOWNLINK}kbit burst 15k prio 1
tc class add dev $IFACE parent 1:2 classid 1:20 htb rate ${UPLINK}kbit burst 15k prio 1

# Filtrowanie ruchu DNS (port 53), HTTPS (port 443) oraz ICMP
tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip dport 53 0xffff flowid 1:10
tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip sport 53 0xffff flowid 1:20
tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip dport 443 0xffff flowid 1:10
tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip sport 443 0xffff flowid 1:20
tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip protocol 1 0xff flowid 1:10  # ICMP

# Reguła dla pozostałego ruchu
tc class add dev $IFACE parent 1:1 classid 1:30 htb rate $((DOWNLINK-1000))kbit burst 15k prio 2
tc class add dev $IFACE parent 1:2 classid 1:40 htb rate $((UPLINK-500))kbit burst 15k prio 2
tc filter add dev $IFACE protocol ip parent 1:0 prio 2 u32 match ip dst 0.0.0.0/0 flowid 1:30
tc filter add dev $IFACE protocol ip parent 1:0 prio 2 u32 match ip src 0.0.0.0/0 flowid 1:40
