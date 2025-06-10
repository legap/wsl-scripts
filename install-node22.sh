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
echo "Adding ppa repo for nodesource"
echo "--------------------------------------------------------------------------------"
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --batch --yes --dearmor --output "/etc/apt/trusted.gpg.d/nodesource.gpg"

echo "--------------------------------------------------------------------------------"
echo "Configuring node-apt-source"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/apt/sources.list.d/nodesource.list <<EOT
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main
EOT

echo "--------------------------------------------------------------------------------"
echo "Adding ppa repo for yarn"
echo "--------------------------------------------------------------------------------"
curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --batch --yes --dearmor --output "/etc/apt/trusted.gpg.d/yarn.gpg"

echo "--------------------------------------------------------------------------------"
echo "Configuring yarn-apt-source"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/apt/sources.list.d/yarn.list <<EOT
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main
EOT

echo "--------------------------------------------------------------------------------"
echo "Installing nodejs apt package"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y nodejs yarn

echo "--------------------------------------------------------------------------------"
echo "Configure environment variables for node"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/profile.d/node-config.sh <<EOT
export NODE_OPTIONS="--use-openssl-ca"
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/ca-certificates.crt"
EOT
