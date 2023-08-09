#!/bin/bash

echo "Etap 1: Wybór interfejsu"
# Wybór interfejsu
read -p "Wybierz interfejs (wlan0/eth0): " INTERFACE

if [ "$INTERFACE" != "wlan0" ] && [ "$INTERFACE" != "eth0" ]; then
    echo "Nieprawidłowy interfejs!"
    exit 1
fi

echo "Etap 2: Czyszczenie istniejących reguł"
# Usuń istniejące reguły i tabele
nft flush ruleset

echo "Etap 3: Ustawienie tabeli i łańcuchów"
# Zastosuj nowe reguły nftables

# Zdefiniuj zmienne, jeśli są potrzebne
rpi="100.91.137.46"
nlaptop="100.67.253.99"
bpc="100.77.75.91"

echo "Etap 3: Ustawienie tabeli i łańcuchów"

# Zastosuj nowe reguły nftables
nft -f - <<EOF

table inet filter {
    set whitelist {
        type ipv4_addr
        elements = { rpi, nlaptop, bpc }
    }

    set blacklist {
        type ipv4_addr
        flags timeout
        timeout 1d
    }

    chain input {
        type filter hook input priority 0; 

        # Zasady podstawowe
        ct state established,related accept
        ct state invalid drop

        # Pozwól na ruch loopback
        iifname "lo" accept

        # ICMP (ping)
        ip protocol icmp icmp type { echo-request, echo-reply, destination-unreachable, time-exceeded } accept

        # SSH tylko dla określonych nazw domenowych
        tcp dport 1499 ip saddr @whitelist accept
        tcp dport 1499 log prefix "Nieautoryzowane próby połączenia SSH: " add @blacklist { ip saddr } drop

        # Discord (HTTPS i WebRTC)
        tcp dport { 443, 3478-3480 } accept
        udp dport { 3478-3480 } accept

        # Odrzuć pozostały ruch
        ip saddr @blacklist drop
        drop
    }

    chain forward {
        type filter hook forward priority 0; 
        drop
    }

    chain output {
        type filter hook output priority 0;

	# Pozwól na wychodzące połączenia SSH na porcie 1499 do hostów na liście whitelist
        tcp sport 1499 ip daddr @whitelist accept
        accept
    }
}

EOF


echo  "$NFT_SCRIPT" > /tmp/nft_script.tmp
nft -f /tmp/nft_script.tmp
rm /tmp/nft_script.tmp

echo "Etap 4: Zapisywanie reguł jako trwałe"
# Zapisz reguły jako trwałe
nft list ruleset > /etc/nftables.conf

echo "Etap 5: Zakończenie"
echo "Reguły nftables zostały zastosowane dla interfejsu $INTERFACE i zapisane jako trwałe."

