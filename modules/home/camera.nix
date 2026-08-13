{ pkgs, ... }:
{
  home.packages = with pkgs; [
    guvcview
  ];
}
