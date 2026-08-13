{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "manhattan-cafe-cursors";
  version = "1.9.0";

  # Trimmed copy of the vsthemes.org zip: only the Linux (XCursor) and
  # Hyprcursor payloads are kept. Windows/, the PDFs and source.url are dropped.
  src = ./source;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    themeDir="$out/share/icons/Manhattan-Cafe"
    mkdir -p "$themeDir"

    # --- XCursor (X11 / GTK / most Wayland toolkits via xcursor fallback) ---
    cp -r "$src/Linux/cursors" "$themeDir/cursors"
    cp "$src/Linux/index.theme" "$themeDir/index.theme"
    # the upstream index.theme has CRLF line endings; normalize them
    sed -i 's/\r$//' "$themeDir/index.theme"

    # --- Hyprcursor (native format Hyprland prefers) ---
    cp "$src/Hyprcursor/manifest.hl" "$themeDir/manifest.hl"
    sed -i 's/\r$//' "$themeDir/manifest.hl"
    cp -r "$src/Hyprcursor/hyprcursors" "$themeDir/hyprcursors"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Manhattan Cafe cursor theme, XCursor + Hyprcursor formats (vsthemes.org)";
    homepage = "https://vsthemes.org/";
    license = licenses.unfree; # upstream license unclear/not specified — adjust if you find one
    platforms = platforms.linux;
  };
}
