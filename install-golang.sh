#!/usr/bin/env bash
set -e

# Initial gate
if [ "$(id -u)" -eq 0 ]; then
    echo "Please rerun this script as regular user (without sudo)"
    echo "Otherwise we can't configure go for your user"
    exit 1
fi

echo "--------------------------------------------------------------------------------"
echo "Installing required packages"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y gpg

echo "--------------------------------------------------------------------------------"
echo "Adding ppa repo for golang"
echo "--------------------------------------------------------------------------------"
curl "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x52B59B1571A79DBC054901C0F6BC817356A3D45E" | sudo gpg --batch --yes --dearmor --output "/etc/apt/trusted.gpg.d/longsleep_ubuntu_golang-backports.gpg"


echo "--------------------------------------------------------------------------------"
echo "Configuring golang-apt-source"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/apt/sources.list.d/golang.list <<EOT
deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/trusted.gpg.d/longsleep_ubuntu_golang-backports.gpg] http://ppa.launchpad.net/longsleep/golang-backports/ubuntu jammy main
EOT

echo "--------------------------------------------------------------------------------"
echo "Installing golang-go apt package"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y golang-go
