{ lib, pkgs, host, ... }:
let
  gtk-theme-name = "Colloid-Green-Dark-Gruvbox";
  gtk-theme = pkgs.colloid-gtk-theme.override {
    colorVariants = [ "dark" ];
    themeVariants = [ "green" ];
    tweaks = [
      "gruvbox"
      "rimless"
      "float"
    ];
  };
  icon-theme-name = "Papirus-Dark";

  # was pkgs.manhattan-cafe-cursor, which isn't a real nixpkgs package --
  # that's why the theme "set" (name/size were written to dconf/env) but
  # nothing actually scaled: there was no working package behind it, and
  # more importantly no hyprcursor output for Hyprland itself to use.
  rice-shower-cursor = pkgs.callPackage ./../../pkgs/rice-shower-cursor { };
  cursor-name = "rice-shower"; # no spaces -- matches the dir under share/icons
  cursor-size = 48;
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.symbols-only
    twemoji-color-font
    noto-fonts-color-emoji
    fantasque-sans-mono
    maple-mono-custom
  ];
  gtk = {
    enable = true;
    font = {
      name = "Maple Mono";
      size = if (host == "p14s") then 14 else 12;
    };
    theme = {
      name = gtk-theme-name;
      package = gtk-theme;
    };
    iconTheme = {
      name = icon-theme-name;
      package = pkgs.papirus-icon-theme.override { color = "green"; };
    };

    cursorTheme = {
      name = cursor-name;
      package = rice-shower-cursor;
      size = cursor-size;
    };
    #
    # cursorTheme = {
    #   name = "Bibata-Modern-Ice";
    #   package = pkgs.bibata-cursors;
    #   size = 24;
    # };
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = lib.mkForce true;
      };
    };
    gtk4 = {
      theme = {
        name = gtk-theme-name;
        package = gtk-theme;
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = lib.mkForce true;
      };
    };
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = gtk-theme-name;
      icon-theme = icon-theme-name;
      color-scheme = "prefer-dark";
      cursor-theme = cursor-name;
      cursor-size = cursor-size;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = cursor-name;
    package = rice-shower-cursor;
    size = cursor-size;

    # This is the piece that was missing: without it, Hyprland (and any
    # server-side-cursor app -- Qt, foot, kitty) never gets HYPRCURSOR_THEME/
    # HYPRCURSOR_SIZE and falls back to a non-scaled XCursor bitmap.
    hyprcursor = {
      enable = true;
      size = cursor-size;
    };
  };
  # home.pointerCursor = {
  #   name = "Bibata-Modern-Ice";
  #   package = pkgs.bibata-cursors;
  #   size = 24;
  # };
}
