#!/usr/bin/env bash
set -e

MAJOR_VERSION=3
INSTALL_DIR=/opt/maven/
WORKING_DIR=/tmp/

# Initial gate
if [ "$(id -u)" -eq 0 ]; then
  echo "Please rerun this script as regular user (without sudo)"
  echo "Otherwise we can't configure maven for your user"
  exit 1
fi

# make sure the installation directory exists
sudo mkdir --parents "${INSTALL_DIR}"

latest=$(curl -s https://dlcdn.apache.org/maven/maven-${MAJOR_VERSION}/ |
  sed -ne 's/[^0-9]*\(\([0-9]\+\.\)\{0,2\}[0-9]\+\).*/\1/p' |
  grep -E "^${MAJOR_VERSION}(\.|$)" |
  sort -Vr |
  head -1)

# Get installed versions from the installation dir
readarray -t installed < <(
  find /opt/maven/ -maxdepth 1 -type d -name "apache-maven-${MAJOR_VERSION}*" |
    sed -E 's#.*/apache-maven-##'
)

echo "--------------------------------------------------------------------------------"
echo "Latest Maven ${MAJOR_VERSION} version: $latest"
echo "--------------------------------------------------------------------------------"
echo "Installed versions:"
for v in "${installed[@]}"; do
  echo "- $v"
done
echo "--------------------------------------------------------------------------------"

if [[ " ${installed[*]} " =~ $latest ]]; then
  echo "✅ You have the latest Maven ${MAJOR_VERSION} version installed."
  exit 0
fi

echo "⚠️  Latest version ($latest) is NOT installed."
echo
echo "--------------------------------------------------------------------------------"
echo "Installing maven ${latest} in directory ${INSTALL_DIR}"
echo "--------------------------------------------------------------------------------"

# download and extract the current version into the installation directory
wget --no-verbose --directory-prefix=${WORKING_DIR} "https://dlcdn.apache.org/maven/maven-${MAJOR_VERSION}/${latest}/binaries/apache-maven-${latest}-bin.tar.gz"
sudo tar xzf "${WORKING_DIR}apache-maven-${latest}-bin.tar".gz -C "${INSTALL_DIR}"

# cleanup the downloaded file
rm "${WORKING_DIR}apache-maven-${latest}-bin.tar.gz"

# create or update a symlink to the latest version
sudo ln -sfn "/opt/maven/apache-maven-${latest}" /opt/maven/current

echo "--------------------------------------------------------------------------------"
echo "Configure environment variables for maven"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/profile.d/maven-config.sh <<'EOT'
export M2_HOME=/opt/maven/current

if [[ ":$PATH:" != *":$M2_HOME/bin:"* ]]; then
    export PATH="$M2_HOME/bin:$PATH"
fi
EOT
