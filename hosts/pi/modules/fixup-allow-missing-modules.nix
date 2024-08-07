# Issue: https://github.com/NixOS/nixos-hardware/issues/360#issuecomment-1009626988
# Workaround: https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
{ config
, pkgs
, ...
}:
let
  overlay-allowMissing = final: super: {
    makeModulesClosure = x:
      super.makeModulesClosure (x // { allowMissing = true; });
  };
in
{
  nixpkgs.overlays = [ overlay-allowMissing ];
}
