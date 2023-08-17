#!/bin/bash

# Ustaw nazwę mostu
BRIDGE_NAME="br0"

# Utwórz most sieciowy
cat << EOF > /etc/systemd/network/${BRIDGE_NAME}.netdev
[NetDev]
Name=${BRIDGE_NAME}
Kind=bridge
EOF

if [ $? -eq 0 ]; then
    echo "Most sieciowy ${BRIDGE_NAME} został utworzony."
else
    echo "Błąd podczas tworzenia mostu sieciowego ${BRIDGE_NAME}."
    exit 1
fi

# Podłącz główny interfejs sieciowy (np. eth0) do mostu
cat << EOF > /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
Bridge=${BRIDGE_NAME}
EOF

if [ $? -eq 0 ]; then
    echo "Główny interfejs sieciowy został podłączony do mostu ${BRIDGE_NAME}."
else
    echo "Błąd podczas podłączania głównego interfejsu sieciowego do mostu ${BRIDGE_NAME}."
    exit 1
fi

# Konfiguracja mostu tak, aby otrzymywał adres IP z DHCP
cat << EOF > /etc/systemd/network/${BRIDGE_NAME}.network
[Match]
Name=${BRIDGE_NAME}

[Network]
DHCP=yes
EOF

if [ $? -eq 0 ]; then
    echo "Most ${BRIDGE_NAME} skonfigurowany do korzystania z DHCP."
else
    echo "Błąd podczas konfigurowania mostu ${BRIDGE_NAME} do korzystania z DHCP."
    exit 1
fi
echo "zatrzymanie networkd"
systemctl stop systemd-networkd
sleep 3
echo "wyłączenie networkd"
systemctl disable systemd-networkd
sleep 3
echo "ustawienie br0 jako master dla eth0"
ip link set eth0 master br0
sleep 3
echo "ustawianie przykładowego ip dla interfejsu"
ip addr add 192.168.10.3/16 dev br0 brd 192.168.255.255 ## You can add any IP. It is just temporary and it will change for your LAN IP later.
sleep 3
echo "Podniesienie obu interfejsów"
ip link set up eth0 && ip link set up br0
sleep 3
systemctl enable systemd-networkd
systemctl start systemd-networkd
