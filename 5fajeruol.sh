#!/bin/bash

# Ustawienie domyślnej polityki na DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Zezwól na cały ruch wychodzący
iptables -A OUTPUT -o eth0 -j ACCEPT
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Zezwól na ruch lokalny
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Zezwól na ruch DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT

# Lista adresów IP, które mają dostęp do SSH
ALLOWED_IPS="100.77.75.91,100.67.253.99,100.91.137.46"

# Zezwól na ruch SSH dla dozwolonych adresów IP
iptables -A INPUT -p tcp -m multiport --sports 22,1499 -s $ALLOWED_IPS -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 22,1499 -d $ALLOWED_IPS -j ACCEPT

# Zezwól na pingowanie ALLOWED_IPS i aby ALLOWED_IPS mogły Cię pingować
for ip in $(echo $ALLOWED_IPS | tr "," "\n"); do
    iptables -A INPUT -p icmp --icmp-type echo-request -s $ip -j ACCEPT
    iptables -A OUTPUT -p icmp --icmp-type echo-reply -d $ip -j ACCEPT
    iptables -A OUTPUT -p icmp --icmp-type echo-request -d $ip -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type echo-reply -s $ip -j ACCEPT
done

# Reguły przeciwdziałające atakom brute-force na SSH (port 22 i 1499)
iptables -A INPUT -p tcp -m multiport --dports 22,1499 -m recent --rcheck --seconds 3600 --name sshbf --rsource --hitcount 6 -j DROP
iptables -A INPUT -p tcp -m multiport --dports 22,1499 -m recent --set --name sshbf --rsource
iptables -A INPUT -p tcp -m multiport --dports 22,1499 -j ACCEPT

echo "Konfiguracja zabezpieczeń zakończona!"

