{ pkgs, ... }:

let
  launcher = pkgs.callPackage ./launcher.nix { };
in
{
  home.packages = [ launcher ];
}
