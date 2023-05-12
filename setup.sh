#!/bin/bash

set -ex

# Capture my current user

USER=$(whoami)

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

# Install  Nix home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# May need some stuff from unstabled nix channel, so add that channel too. 
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
# Make sure OpenGL works for applicaitons installed via home-manager e.g alacritty
nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl 
nix-env -iA nixgl.auto.nixGLDefault

nix-channel --update


# TODO: Add steps to install git temporarity and clone the repo before calling home-manager swtich


## TODO Add a step to create a symlink to home.nix in this repo. 

# e.g. ln -s ./home.nix  $HOME/.config/home-manager/home.nix (TODO: make sure to drive path to home.nix in this repo)

# Install/setup everyting via home-manager now
home-manager switch

# Our zsh is now installed via home-manager, we must add it to the list of shells and change shell for the
# curent user.
echo "/home/$USER/.nix-profile/bin/zsh" |  sudo tee --append /etc/shell
chsh -s $(which zsh)


