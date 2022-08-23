#! /usr/bin/env nix-shell
#! nix-shell -i bash -p tree

set -e

echo "Build the Image"
nix build .

echo "🔍 Find result"
RESULT=$(readlink -f ./result)
tree -l $RESULT
IMAGE=$(find $RESULT -name 'nixos-sd-image*.img')

echo "📑 Copy image to workspace"
cp -f "$IMAGE" .
