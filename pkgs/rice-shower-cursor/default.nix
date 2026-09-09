{ stdenvNoCC, lib }:

# Rice Shower cursor theme, packaged for NixOS/home-manager.
#
# The upstream download already ships two pre-built formats, so this
# derivation is just a "copy into place" job -- no clickgen/ctgen build step
# needed:
#   ./theme/manifest.hl + ./theme/hyprcursors/*.hlc   -> native Hyprcursor (scales properly)
#   ./theme/cursors/*                                  -> classic XCursor (X11/XWayland/GTK fallback)
#
# Both live under the SAME theme name ("rice-shower") so a single
# home.pointerCursor.name value works for x11, gtk and hyprcursor alike.

stdenvNoCC.mkDerivation {
  pname = "rice-shower-cursor";
  version = "1.9.0";

  # Vendored locally -- point this at wherever you keep the ./theme dir
  # (e.g. inside your dotfiles/flake repo).
  src = ./theme;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -dm755 $out/share/icons/rice-shower
    cp -r $src/hyprcursors $out/share/icons/rice-shower/hyprcursors
    cp -r $src/cursors     $out/share/icons/rice-shower/cursors
    install -m644 $src/manifest.hl  $out/share/icons/rice-shower/manifest.hl
    install -m644 $src/index.theme $out/share/icons/rice-shower/index.theme

    runHook postInstall
  '';

  meta = with lib; {
    description = "Rice Shower cursor theme (Hyprcursor + XCursor)";
    platforms = platforms.linux;
  };
}
