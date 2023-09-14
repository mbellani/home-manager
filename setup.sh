#!/bin/bash

set -ex

# Capture my current user

USER=$(whoami)
PWD=$(pwd)

# Get rid of the snap garbage first
if command -v snap &> /dev/null
then
  echo "Found snap on the system... unsnapping the system"
  snap list | awk 'awk!/Name|^core/ {print $1}' | xargs  -I{} sudo snap remove --purge {:q:}
  sudo apt remove --purge -y snapd gnome-software-plugin-snap
fi

# Make sure snpas don't make their way back into the system ever
sudo touch /etc/apt/preferences.d/nosnap.pref
sudo sh -c "cat > /etc/apt/preferences.d/nosnap.pref" <<-EOF
  Package: snapd
  Pin: release a=*
  Pin-Priority: -10
EOF

# Make sure that we didn't cause any errors by running sudo apt update
sudo apt update

# Instlal gnome
sudo sh -c "sudo apt install --no-install-recommends gnome-software"

# Remove any leftovers
sudo apt -y autoremove

# Install curl via apt, we need it for installing nix
sudo apt install -y curl

# Install Nix package manager
sh <(curl -L https://nixos.org/nix/install) --daemon

read -p "Nix pakcage namager install, hit any key to exit and restart a new shell to run setup-home-manager.sh"

exit 0
