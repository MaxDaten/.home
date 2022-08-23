{
  config,
  pkgs,
  ...
}: let
  overlay-allowMissing = final: super: {
    makeModulesClosure = x:
      super.makeModulesClosure (x // {allowMissing = true;});
  };
in {
  nixpkgs.overlays = [overlay-allowMissing];
}
