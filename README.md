# jloos nix/nixos configs

Inspired by <DAlperin/dotfiles>.

## Structure

TBD

## Raspberry Pi 4 NixOS

Flake based nixos configuration including building a customized install image via docker (mildly inspired by <https://github.com/zefhemel/nix-docker>).

### Build & Provision Image (arm only)

Run `./build.sh`.

This builds an .img based on this flake and writes it onto an sd which the raspberry pi boots from.

This utilize docker to build an aarch64-linux image. Currently nix cross compilation does not work for me this is why only aarch64 is supported.

### Switch nixos to this configuration

Either run on the pi:

```bash
sudo nixos-rebuild switch --flake github:MaxDaten/raspi-nixos/<commit-sha>
# for example:
# sudo nixos-rebuild switch --flake github:MaxDaten/raspi-nixos/12e09b66f64f46b97236ffb2eba97e41969b4c1f
```

or remotely:

```bash
nixos-rebuild --flake .#pi4-nixos \
  --target-host pi4-nixos --build-host pi4-nixos \
  switch
```

## TODO

- [ ] Integrate already present home-manager managed home configs for `users.jloos`
- [ ] Secret management via [sops-nix](https://github.com/Mic92/sops-nix)
  - <https://xeiaso.net/blog/nixos-encrypted-secrets-2021-01-20>
