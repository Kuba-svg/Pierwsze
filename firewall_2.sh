
#!/bin/bash

# Zmienne
IPT="/sbin/iptables"
PUB_IF="wlan0" # Przykładowa nazwa interfejsu
SSH_IPS=("192.168.1.100" "192.168.1.101") # Lista #dozwolonych adresów IP dla SSH
SSH_PORT="22" #Zrób taki jaki Ci pasuje

# Czyszczenie starych reguł
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT

# Ochrona przed atakami typu smurf
$IPT -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
$IPT -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
$IPT -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second --limit-burst 2 -j ACCEPT

# Ochrona przed atakami IP spoofing
$IPT -A INPUT -s 10.0.0.0/8 -j DROP
$IPT -A INPUT -s 172.16.0.0/12 -j DROP
$IPT -A INPUT -s 192.168.0.0/16 -j DROP
$IPT -A INPUT -s 224.0.0.0/4 -j DROP
$IPT -A INPUT -d 224.0.0.0/4 -j DROP
$IPT -A INPUT -s 240.0.0.0/5 -j DROP
$IPT -A INPUT -d 240.0.0.0/5 -j DROP
$IPT -A INPUT -s 0.0.0.0/8 -j DROP
$IPT -A INPUT -d 0.0.0.0/8 -j DROP
$IPT -A INPUT -d 239.255.255.0/24 -j DROP
$IPT -A INPUT -d 255.255.255.255 -j DROP

# Ochrona przed atakami port scanning
$IPT -N port-scanning
$IPT -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
$IPT -A port-scanning -j DROP

# Ochrona przed atakami ping of death
$IPT -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 3 -j ACCEPT

# Ograniczenie połączeń SYN
$IPT -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT

# Otwarcie portów dla połączeń przychodzących
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Pozwolenie na przychodzące połączenia SSH tylko z określonych adresów IP
for ip in "${SSH_IPS[@]}"
do
$IPT -A INPUT -p tcp -s $ip --dport $SSH_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -p tcp --sport $SSH_PORT -m state --state ESTABLISHED -j ACCEPT
done

$IPT -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
$IPT -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
$IPT -A INPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
$IPT -A INPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
# Blokowanie wszystkiego innego
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT

# Zapisanie reguł
/sbin/iptables-save > /etc/iptables/rules.v4

echo "Konfiguracja iptables została zakończona pomyślnie!" 

