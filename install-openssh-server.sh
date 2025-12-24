#!/usr/bin/env bash
set -e

# Initial gate
if [ "$(id -u)" -eq 0 ]; then
    echo "Please rerun this script as regular user (without sudo)"
    echo "Otherwise we can't configure the open-ssh server for you"
    exit 1
fi

echo "--------------------------------------------------------------------------------"
echo "Adding openssh-server"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y openssh-server

echo "--------------------------------------------------------------------------------"
echo "starting the ssh service"
echo "--------------------------------------------------------------------------------"
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
