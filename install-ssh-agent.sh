#!/usr/bin/env bash
set -e

# Initial gate
if [ "$(id -u)" -eq 0 ]; then
    echo "Please rerun this script as regular user (without sudo)"
    echo "Otherwise we can't configure the ssh agent for your user"
    exit 1
fi

echo "--------------------------------------------------------------------------------"
echo "Installing required packages"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y openssh-client

echo "--------------------------------------------------------------------------------"
echo "Adding startup script for ssh agent"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/profile.d/start-ssh-agent.sh <<'EOT'
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
EOT
