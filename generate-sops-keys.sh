#! /usr/bin/env bash

SOPS_AGE_KEY_DIRECTORY="${HOME}/.config/sops/age"
echo "Generate key in ${SOPS_AGE_KEY_DIRECTORY}"

mkdir -p $SOPS_AGE_KEY_DIRECTORY
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > $SOPS_AGE_KEY_DIRECTORY/keys.txt

echo "Public key:"
age-keygen -y $SOPS_AGE_KEY_DIRECTORY/keys.txt