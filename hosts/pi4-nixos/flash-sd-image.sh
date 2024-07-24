#! /usr/bin/env nix-shell
#! nix-shell -i bash -p tree findutils

set -euo pipefail

echo "Build image via docker"
nix build .#packages.aarch64-linux.default --system 'aarch64-linux' --max-jobs 0
IMAGE=$(find ./result/sd-image/ -name 'nixos-sd-image*.img' -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")

read -p "Write image ${IMAGE}? (This may take a while) [yn]: " WRITE_IMAGE

case $WRITE_IMAGE in
    [Yy]* ) 
        echo "✍️ Write image to sd card"
        diskutil list
        
        read -p "Enter device: " TARGET_SD
        
        echo "Unmounting disk to allow writing to disk"
        sudo diskutil unmount $TARGET_SD || true
        sudo diskutil unmountDisk $TARGET_SD

        echo "Start writing to disk"
        sudo dd if="${IMAGE}" of="${TARGET_SD}" bs=8M conv=fsync status=progress

        echo "Done... ejecting sd"
        sudo diskutil eject $TARGET_SD
        ;;
    * ) exit;;
esac
