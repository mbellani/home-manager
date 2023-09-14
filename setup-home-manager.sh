#!/bin/bash

set -ex

# Capture my current user
USER=$(whoami)
PWD=$(pwd)

# Install  Nix home-manager
#nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
#nix-channel --update
#nix-shell '<home-manager>' -A install

# May need some stuff from unstabled nix channel, so add that channel too. 
#nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
# Make sure OpenGL works for applicaitons installed via home-manager e.g alacritty
#nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl 
#nix-channel --update
#nix-env -iA nixgl.auto.nixGLDefault


rm -rf $HOME/.config/home-manager/home.nix
ln -s $PWD/home.nix $HOME/.config/home-manager/home.nix
ln -s $PWD/nix.conf $HOME/.config/nix/nix.conf

# Install/setup everyting via home-manager now
home-manager switch

# Our zsh is now installed via home-manager, we must add it to the list of shells and change shell for the
# curent user.

command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"
