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

### Install NixOS

Once the pi started, connect via ssh `ssh jloos@pi4-nixos` or as root `ssh root@pi4-nixos`.

```bash
git clone git@github.com:MaxDaten/.home.git
sudo ln -sf /home/jloos/.home/flake.nix /etc/nixos/flake.nix
sudo nixos-install --root / --flake
reboot
```

### Apply new NixOS configuration

Either run on the pi:

```bash
sudo nixos-rebuild switch --flake github:MaxDaten/.home/<commit-sha>
# for example:
# sudo nixos-rebuild switch --flake github:MaxDaten/.home/12e09b66f64f46b97236ffb2eba97e41969b4c1f
```

or remotely:

```bash
nixos-rebuild --flake .#pi4-nixos \
  --target-host pi4-nixos --build-host pi4-nixos \
  switch
```

### Use Visual Studio Code remotely

Does not work out of the box but <https://github.com/msteen/nixos-vscode-server> is already installed as a nixos module.
But it has to be [enabled manually on user basis](https://github.com/msteen/nixos-vscode-server#enable-the-service):

```bash
systemctl --user enable auto-fix-vscode-server.service
systemctl --user start auto-fix-vscode-server.service
```

## TODO

- [x] Integrate already present home-manager managed home configs for `users.jloos`
- [x] Secret management via [sops-nix](https://github.com/Mic92/sops-nix)
  - <https://xeiaso.net/blog/nixos-encrypted-secrets-2021-01-20>
- [ ] SOPS for Installer Image? => Pin HOST key
- [ ] Hardware Dashboard
- [ ] Home-Bridge
- [ ] Remote building on pi4
