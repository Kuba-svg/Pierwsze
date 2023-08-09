#!/bin/bash

# Zapisz reguły do pliku tymczasowego
cat > /tmp/nft_script.tmp <<EOF
table inet filter {
    set ssh_blacklist {
        type ipv4_addr
        flags timeout
        timeout 1h
    }

    chain input {
        type filter hook input priority 0;

        # Akceptuj ruch dla istniejących połączeń
        ct state established,related accept

        # Odrzuć ruch dla nieprawidłowych połączeń
        ct state invalid drop

        # Ograniczenie połączeń SSH do 5/min
        tcp dport 1499 ip saddr != @ssh_blacklist ct state new limit rate 5/minute accept

        # Dodawanie do blacklisty po przekroczeniu limitu
        tcp dport 1499 ip saddr != @ssh_blacklist ct state new log prefix "SSH brute-force attempt: " add @ssh_blacklist { ip saddr } drop

        # Odrzuć ruch z adresów IP na czarnej liście
        ip saddr @ssh_blacklist drop

        # Akceptuj ruch loopback
        iifname "lo" accept

        # Odrzuć pozostały ruch
        drop
    }

    chain output {
        type filter hook output priority 0;

        # Akceptuj ruch dla istniejących połączeń
        ct state established,related accept

        # Akceptuj ruch wychodzący SSH
        tcp dport 1499 accept

        # Akceptuj pozostały ruch wychodzący
        accept
    }
}
EOF

# Zastosuj reguły z pliku tymczasowego
nft -f /tmp/nft_script.tmp

# Usuń plik tymczasowy
rm /tmp/nft_script.tmp

echo "Reguły nftables zostały zastosowane."

