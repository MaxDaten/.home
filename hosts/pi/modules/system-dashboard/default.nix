{ config
, pkgs
, ...
}: {
  imports = [
    ./grafana.nix
    ./prometheus.nix
  ];
}
