#!/bin/bash

# Sprawdź, czy unattended-upgrades jest już zainstalowany
if ! dpkg -l | grep -q unattended-upgrades; then
    echo "Instalowanie unattended-upgrades..."
    sudo apt-get install unattended-upgrades -y
    echo "Zainstalowano unattended-upgrades."
else
    echo "unattended-upgrades jest już zainstalowany."
fi

# Ścieżka do pliku konfiguracyjnego
CONFIG_FILE="/etc/apt/apt.conf.d/50unattended-upgrades"

# Wpisy do dodania do pliku konfiguracyjnego
CONFIG_ENTRIES=(
"\"o=Ubuntu,a=\${distro_codename}\";"
"\"o=Ubuntu,a=\${distro_codename}-security\";"
"\"o=Ubuntu,a=\${distro_codename}-updates\";"
"\"o=Ubuntu,a=\${distro_codename}-proposed\";"
"\"o=Ubuntu,a=\${distro_codename}-backports\";"
)

echo "Konfiguracja unattended-upgrades..."

# Sprawdź, czy każdy wpis jest już obecny w pliku konfiguracyjnym, a jeśli nie, dodaj go
for entry in "${CONFIG_ENTRIES[@]}"; do
    if ! grep -q "$entry" "$CONFIG_FILE"; then
        echo "Dodawanie wpisu do pliku konfiguracyjnego: $entry"
        echo "$entry" | sudo tee -a "$CONFIG_FILE"
    else
        echo "Wpis jest już obecny w pliku konfiguracyjnym: $entry"
    fi
done

echo "Konfiguracja zakończona."

echo "Włączanie unattended-upgrades..."
sudo dpkg-reconfigure --priority=low unattended-upgrades -f noninteractive
echo "unattended-upgrades włączony."

echo "Sprawdzanie statusu unattended-upgrades..."
sudo unattended-upgrade --dry-run --debug
echo "Sprawdzanie zakończone."

