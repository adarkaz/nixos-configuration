# Rice Shower cursor for NixOS + Hyprland (home-manager)

Your download already contained a proper Hyprcursor build (`Hyprcursor/manifest.hl` +
`hyprcursors/*.hlc`) alongside the classic XCursor bitmaps (`Linux/cursors/*`).
This folder repackages both under one theme name (`rice-shower`) so a single
`home.pointerCursor.name` works everywhere.

## Why it "sets but doesn't scale"

Almost always this means only the **XCursor** side got configured
(`XCURSOR_THEME`/`XCURSOR_SIZE`), while `HYPRCURSOR_THEME`/`HYPRCURSOR_SIZE`
were never set. Hyprland and any server-side-cursor app (Qt, foot, kitty,
the Hyprland desktop cursor itself) then falls back to rendering a fixed-size
XCursor bitmap directly, which doesn't scale with monitor scale/HiDPI at all
— it just looks "off" and annoying. GTK apps that only read gsettings/dconf
have the same problem from the other direction. The fix is to set all four
in lockstep and reload GTK via gsettings, which is what the provided
home-manager snippet does.

## Files

- `theme/` — the actual cursor theme, laid out as it needs to end up under
  `share/icons/rice-shower/`:
  - `manifest.hl`, `hyprcursors/*.hlc` — native Hyprcursor (scales natively, no bitmap scaling)
  - `cursors/*` — XCursor bitmaps, for XWayland/GTK/anything that hasn't adopted hyprcursor
  - `index.theme` — makes it a well-formed XCursor/icon theme
- `default.nix` — a tiny `stdenvNoCC.mkDerivation` that just installs `theme/`
  into `$out/share/icons/rice-shower`. No build step needed (yours came pre-built).
- `home-manager-snippet.nix` — wires it into `home.pointerCursor`,
  `wayland.windowManager.hyprland.settings.env`, and an `exec-once` gsettings
  fallback.

## Setup

1. Copy this whole `rice-shower-cursor/` folder into your nix config repo,
   e.g. `~/dotfiles/modules/rice-shower-cursor/`.
2. In your `home.nix`, import/merge in `home-manager-snippet.nix` (adjust the
   `./modules/rice-shower-cursor` path to wherever you put it).
3. `home-manager switch` (or rebuild your flake).
4. Fully restart your Hyprland session (logout/login, not just reload) so the
   env vars in `wayland.windowManager.hyprland.settings.env` take effect —
   `env =` lines are read once at compositor start, `hyprctl reload` alone
   won't re-export them.
5. Sanity check:
   ```
   echo $HYPRCURSOR_THEME $HYPRCURSOR_SIZE $XCURSOR_THEME $XCURSOR_SIZE
   hyprctl getoption cursor:no_hardware_cursors
   ```

## If it still doesn't scale on one monitor but not others

That's a different, known Hyprland bug with the hardware cursor plane on
mixed-scale multi-monitor setups (hyprwm/Hyprland#3969) — uncomment the
`cursor.no_hardware_cursors = true;` line left commented in the snippet. It
forces software cursor compositing, which is correctly scaled at the cost of
negligible GPU overhead.
