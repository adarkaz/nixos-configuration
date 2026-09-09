{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;

  # services.desktopManager.plasma6.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.hyprland = {
    enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
    };

    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
