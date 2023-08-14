#!/bin/bash

# Zmienne
DEV=eth0
UPLINK=10000  # 10 Mbit/s
DOWNLINK=20000  # 20 Mbit/s

# Czyszczenie istniejących reguł
tc qdisc del dev $DEV root
tc qdisc del dev $DEV ingress

# Ustawienie korzeniowy qdisc dla uplink
tc qdisc add dev $DEV root handle 1: hfsc default 30

# Ustawienie korzeniowy qdisc dla downlink
tc qdisc add dev $DEV handle ffff: ingress

# Ustawienie klasy bazowej dla uplink
tc class add dev $DEV parent 1: classid 1:1 hfsc sc rate ${UPLINK}kbit ul rate ${UPLINK}kbit

# Klasy dla poszczególnych usług
## DNS
tc class add dev $DEV parent 1:1 classid 1:10 hfsc ls rate ${UPLINK}kbit ul rate ${UPLINK}kbit
tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip dport 53 0xffff flowid 1:10
tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip sport 53 0xffff flowid 1:10

## HTTPS
tc class add dev $DEV parent 1:1 classid 1:20 hfsc ls rate ${UPLINK}kbit ul rate ${UPLINK}kbit
tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip dport 443 0xffff flowid 1:20
tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip sport 443 0xffff flowid 1:20

## ICMP
tc class add dev $DEV parent 1:1 classid 1:30 hfsc ls rate ${UPLINK}kbit ul rate ${UPLINK}kbit
tc filter add dev $DEV protocol ip parent 1: prio 1 u32 match ip protocol 1 0xff flowid 1:30

# Klasy dla reszty ruchu
tc class add dev $DEV parent 1:1 classid 1:40 hfsc ls rate $((UPLINK/10))kbit ul rate ${UPLINK}kbit
tc qdisc add dev $DEV parent 1:40 handle 40: sfq perturb 10
tc filter add dev $DEV protocol ip parent 1: prio 4 u32 match ip dst 0.0.0.0/0 flowid 1:40

# Konfiguracja dla downlink
## Ograniczenie szybkości dla downlink
tc filter add dev $DEV parent ffff: protocol ip u32 match u32 0 0 police rate ${DOWNLINK}kbit burst 10k drop flowid :1

echo "Konfiguracja HFSC została zastosowana!"

