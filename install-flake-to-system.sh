#!/usr/bin/env bash

system=$(uname -v)

if [[ $system == *"NixOS"* ]]; 
then
    sudo ln -s $PRJ_ROOT/flake.nix /etc/nixos/flake.nix
else
    echo "Not on NixOS System! Abort!"
    exit 1
fi