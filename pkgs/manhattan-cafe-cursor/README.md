# Manhattan Cafe cursor theme — Nix package

This folder is a self-contained Nix package. Drop the whole
`manhattan-cafe-cursor/` folder into your NixOS config repo, e.g.:

```
~/nixos-config/pkgs/manhattan-cafe-cursor/
  default.nix
  source/
    Linux/{cursors/, index.theme}
    Hyprcursor/{manifest.hl, hyprcursors/}
```

It builds a single theme directory that works both as a normal XCursor
theme (X11 apps, GTK, most toolkits) **and** as a native Hyprcursor theme
(Hyprland), both under the name `Manhattan-Cafe`.

## 1. Reference it from configuration.nix (no flakes)

```nix
{ config, pkgs, ... }:
let
  manhattanCafeCursors = pkgs.callPackage ./pkgs/manhattan-cafe-cursor { };
in
{
  environment.systemPackages = [ manhattanCafeCursors ];
}
```

## 1b. Or from a flake

```nix
# flake.nix
{
  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      manhattanCafeCursors = pkgs.callPackage ./pkgs/manhattan-cafe-cursor { };
    in
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            environment.systemPackages = [ manhattanCafeCursors ];
          }
        ];
      };
    };
}
```

## 2. Set it as the active theme

### Home Manager (recommended — wires GTK + Xcursor env vars for you)

```nix
{ pkgs, ... }:
let
  manhattanCafeCursors = pkgs.callPackage ../pkgs/manhattan-cafe-cursor { };
in
{
  home.pointerCursor = {
    package = manhattanCafeCursors;
    name = "Manhattan-Cafe";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
```

### Plain gsettings (GNOME/GTK only, no home-manager)

```bash
gsettings set org.gnome.desktop.interface cursor-theme 'Manhattan-Cafe'
gsettings set org.gnome.desktop.interface cursor-size 24
```

### Hyprland — use the native Hyprcursor format

Add to `hyprland.conf`:

```
env = HYPRCURSOR_THEME,Manhattan-Cafe
env = HYPRCURSOR_SIZE,24

# fallback for XWayland / non-Hyprcursor-aware apps
env = XCURSOR_THEME,Manhattan-Cafe
env = XCURSOR_SIZE,24

exec-once = hyprctl setcursor Manhattan-Cafe 24
```

Make sure `manhattanCafeCursors` (or the containing `environment.systemPackages`
entry) is actually installed system- or user-wide, otherwise Hyprland/GTK
won't find `/…/share/icons/Manhattan-Cafe`.

## 3. Rebuild

```bash
sudo nixos-rebuild switch   # or: home-manager switch
```

## Notes

- The zip also contained a `Windows/` folder (`.ani`/`.inf` installer) and
  two PDFs — irrelevant on Linux, so they were left out of `source/`.
- `.hlc` files under `Hyprcursor/hyprcursors/` are already-compiled
  Hyprcursor binaries from upstream, so no `hyprcursor` build step is
  needed — the derivation just copies them into place.
- License on vsthemes.org isn't stated; `meta.license` is marked `unfree`
  as a conservative placeholder. Update it if you find the actual terms.
