# Drop this into your home-manager config (e.g. home.nix), and put the
# sibling `theme/` folder + `default.nix` somewhere in your repo, e.g.
# ./modules/rice-shower-cursor/{default.nix,theme/...}

{ config, pkgs, ... }:

let
  riceShowerCursor = pkgs.callPackage ./modules/rice-shower-cursor { };
  cursorName = "rice-shower";
  cursorSize = 24; # pick one size and use it EVERYWHERE below
in
{
  # This is the piece that was almost certainly missing before: it makes
  # home-manager generate matching HYPRCURSOR_THEME/HYPRCURSOR_SIZE *and*
  # XCURSOR_THEME/XCURSOR_SIZE, plus GTK settings, all pointed at the same
  # theme/size. A cursor that "sets but doesn't scale" is the classic symptom
  # of only the X11 side being configured while Hyprland itself (and
  # server-side-cursor apps: Qt, foot, kitty, etc.) fall back to a raw,
  # non-scaled XCursor bitmap because HYPRCURSOR_THEME was never set.
  home.pointerCursor = {
    package = riceShowerCursor;
    name = cursorName;
    size = cursorSize;

    gtk.enable = true;
    x11.enable = true;

    hyprcursor = {
      enable = true;
      size = cursorSize;
    };
  };

  # gtk.enable = true; pulls this in too, but being explicit doesn't hurt,
  # and it's what actually fixes GTK apps that ignore HYPRCURSOR_*.
  gtk.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "HYPRCURSOR_THEME,${cursorName}"
        "HYPRCURSOR_SIZE,${toString cursorSize}"
        "XCURSOR_THEME,${cursorName}"
        "XCURSOR_SIZE,${toString cursorSize}"
      ];

      exec-once = [
        # Belt-and-suspenders: forces GNOME/GTK settings + reloads the
        # cursor at runtime for anything that only reads gsettings/dconf
        # rather than the env vars (this covers most of the "sets but
        # wrong size" GTK app cases).
        "gsettings set org.gnome.desktop.interface cursor-theme '${cursorName}'"
        "gsettings set org.gnome.desktop.interface cursor-size ${toString cursorSize}"
        "hyprctl setcursor ${cursorName} ${toString cursorSize}"
      ];

      # If you run mixed-DPI monitors (different `scale` values per
      # monitor= line) and still see the cursor snap to the wrong size when
      # crossing outputs, this is the known Hyprland hardware-cursor-plane
      # scaling bug (hyprwm/Hyprland#3969). Uncomment to force software
      # cursor compositing, which scales correctly at the cost of a tiny
      # bit of GPU work:
      # cursor.no_hardware_cursors = true;
    };
  };
}
