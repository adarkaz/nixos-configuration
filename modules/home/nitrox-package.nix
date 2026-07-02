{
  stdenv,
  fontconfig,
  dotnetCorePackages,
  libX11,
  libice,
  libsm,
  lib,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "nitrox-bin";
  version = "1.8.1.0";

  src = fetchzip {
    url = "https://github.com/SubnauticaNitrox/Nitrox/releases/download/${version}/Nitrox_${version}_linux_x64.zip";
    hash = "sha256-TQEZjFVKRaQPRshJk6j18hLG9mihLOVrd8ZpzhJtRF0=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    fontconfig
    libX11
    libice
    libsm
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/src/
    cp -r $src/* $out/src/

    mkdir -p $out/bin

    makeWrapper $out/src/Nitrox.Launcher $out/bin/Nitrox.Launcher \
      --set DOTNET_ROOT ${dotnetCorePackages.sdk_9_0}/share/dotnet \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath [
        libX11
        libice
        libsm
      ]}

    makeWrapper $out/src/Nitrox.Server.Subnautica $out/bin/Nitrox.Server.Subnautica \
      --set DOTNET_ROOT ${dotnetCorePackages.sdk_9_0}/share/dotnet \

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://nitrox.rux.gg/";
    description = "Multiplayer Mod for Subnautica";
    platforms = platforms.linux;
  };
}
