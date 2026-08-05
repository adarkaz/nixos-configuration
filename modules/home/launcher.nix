{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libdrm
, libGL
, libnotify
, libpulseaudio
, libuuid
, libxkbcommon
, mesa
, nspr
, nss
, pango
, systemd
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  pname = "rpmrp-launcher";
  version = "0.0.0"; # unknown upstream version - update if the launcher reports one

  src = fetchurl {
    url = "https://files-en.rpmserver.com/download?os=linux";
    # The URL has no filename/extension, so Nix needs a hint to unpack it
    # correctly. Change this if step 1 in README.md shows it's actually
    # an AppImage, .deb, or .zip instead of a tarball.
    name = "rpmrp-launcher.tar.gz";
    sha256 = lib.fakeSha256; # placeholder - see README.md step 2
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  # Best-guess set of runtime libs for an Electron/CEF-style launcher.
  # autoPatchelfHook will tell you at build time if anything is still
  # missing - add the reported package and rebuild.
  buildInputs = [
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus expat
    fontconfig freetype gdk-pixbuf glib gtk3 libdrm libGL libnotify
    libpulseaudio libuuid libxkbcommon mesa nspr nss pango
    systemd zlib
  ] ++ (with xorg; [
    libX11 libXcomposite libXdamage libXext libXfixes libXrandr
    libxcb libxshmfence libXtst libXScrnSaver
  ]);

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/rpmrp-launcher $out/bin
    cp -r . $out/opt/rpmrp-launcher

    # TODO: replace with the real executable name - see README.md step 3
    binName="RPMRP-Launcher"

    makeWrapper "$out/opt/rpmrp-launcher/$binName" "$out/bin/rpmrp-launcher" \
      --chdir "$out/opt/rpmrp-launcher"

    runHook postInstall
  '';

  # Note: no desktop entry here anymore - the Home Manager module
  # (hm-module.nix) declares it via xdg.desktopEntries instead, since
  # that's the idiomatic place for it in a Home Manager setup. If you use
  # this package outside Home Manager, see the commented block at the
  # bottom of hm-module.nix for the equivalent plain nixpkgs version.

  meta = with lib; {
    description = "Launcher for the RPM RolePlay GTA San Andreas Multiplayer (SA-MP) server";
    homepage = "https://rpmserver.com";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    mainProgram = "rpmrp-launcher";
  };
}
