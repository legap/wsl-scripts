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
echo "Configuring adoptium-apt-source"
echo "--------------------------------------------------------------------------------"

# Extract the codename like bookwork, bullseye etc from /etc/os-release
. /etc/os-release
DISTRO=${VERSION_CODENAME}

sudo tee /etc/apt/sources.list.d/adoptium.list <<EOT
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/adoptium.gpg] https://packages.adoptium.net/artifactory/deb ${DISTRO} main
EOT

echo "--------------------------------------------------------------------------------"
echo "Installing temurin apt package"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y temurin-25-jdk

echo "--------------------------------------------------------------------------------"
echo "Configure environment variables for java"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/profile.d/java-config.sh <<EOT
export JAVA_HOME="/usr/lib/jvm/temurin-25-jdk-amd64/"
EOT
