#! /usr/bin/env bash

read -r -d '' HERE_CONFIG <<'EOF'
# required
experimental-features = nix-command flakes
# optional optimization
# Following: https://github.com/nix-community/nix-direnv#installation
keep-derivations = true
keep-outputs = true 
warn-dirty = false
EOF

export NIX_EXTRA_CONF="$HERE_CONFIG"

sh <(curl -L https://nixos.org/nix/install)
