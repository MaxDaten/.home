# jloos nix/nixos configs

Inspired by <DAlperin/dotfiles>.

## Structure

TBD

## Home-Manager

On your macos read the [flake section of home-manager](https://nix-community.github.io/home-manager/index.html#ch-nix-flakes).

Currently run:

```sh
home-manager switch --flake '.#jloos-macos'
```

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

### Secret Management

[sops](https://github.com/mozilla/sops) & [sops-nix](https://github.com/Mic92/sops-nix) is used to manage secrets consumed by nixos.

You have to follow these steps to allow yourself to edit secrets:

1. Get your age compatible key from ssh `./generate-sops-keys.sh`
2. Add your key to `./.sops.yaml`:

  ```yaml
  keys:
    - &user age1m2xmznzaswlsyyrndx5q55tzcdzuxc0nmnawu0q8mnve8vjatyhsn2z6rc
  creation_rules:
    - path_regex: secrets/[^/]+\.yaml$
      key_groups:
      - age:
        - *user
  ```

The machine to consume secrets has to be imported via it's host key:

```bash
# on host machine
cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
```

For me details follow documentation of sops-nix.

## TODO

- [x] Integrate already present home-manager managed home configs for `users.jloos`
- [x] Secret management via [sops-nix](https://github.com/Mic92/sops-nix)
  - <https://xeiaso.net/blog/nixos-encrypted-secrets-2021-01-20>
- [X] Hardware Dashboard
  - [x] Grafana
  - [X] Prometheus
  - [ ] Provision Dashboard via nix
- [x] Network printing
- [ ] Home-Bridge
  - <https://github.com/SquircleSpace/nixos-configuration/tree/master/homebridge>
  - [x] Pin package
  - [ ] Service not starting
- [ ] Add cachix
- [ ] SOPS for Installer Image? => Pin HOST key?
- [ ] Remote building on pi4
