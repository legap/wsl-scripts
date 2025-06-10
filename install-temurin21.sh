#!/usr/bin/env bash
set -e

# Initial gate
if [ "$(id -u)" -eq 0 ]; then
    echo "Please rerun this script as regular user (without sudo)"
    echo "Otherwise we can't configure node for your user"
    exit 1
fi

echo "--------------------------------------------------------------------------------"
echo "Adding basic packages"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install gpg apt-transport-https

echo "--------------------------------------------------------------------------------"
echo "Adding ppa repo for adoptium"
echo "--------------------------------------------------------------------------------"
curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --batch --yes --dearmor --output "/etc/apt/trusted.gpg.d/adoptium.gpg"

echo "--------------------------------------------------------------------------------"
echo "Configuring node-apt-source"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/apt/sources.list.d/adoptium.list <<EOT
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main
EOT

echo "--------------------------------------------------------------------------------"
echo "Installing nodejs apt package"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y temurin-21-jdk
