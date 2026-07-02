{ pkgs, config, user, inputs, ... }:
{
  home.packages = [
    (pkgs.callPackage ./nitrox-package.nix {  })
  ];
}
