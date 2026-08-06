{ lib, appimageTools, fetchzip, writeShellScript }:

let
  pname = "rpmrp-launcher";
  version = "2.7.0";

  # The download is a zip wrapping the actual AppImage. `extension` is
  # needed because the URL itself carries no file extension for fetchzip
  # to guess the archive type from.
  src = fetchzip {
    url = "https://files-en.rpmserver.com/download?os=linux";
    extension = "zip";
    # the zip has the AppImage, a Windows .exe, and a readme all sitting
    # flat at the top level - no single folder to descend into
    stripRoot = false;
    sha256 = "sha256-JCg7xcNuLFGXeTafbJ2NTsZ0YKZYCLvtnTA27SEtaLw="; # <-- put YOUR already-working hash back here, don't leave this placeholder
  };

  # Assumes the AppImage sits at the top level of the zip. If `nix build`
  # can't find it here, run `unzip -l RPMRolePlay-installer.zip` and adjust
  # this path to match the real layout (e.g. "${src}/linux/RPM-RolePlay-...").
  appimage = "${src}/RPM-RolePlay-${version}.AppImage";

  appimageContents = appimageTools.extractType2 { inherit pname version; src = appimage; };

  # The launcher writes logs (and probably downloads extra engine/anti-cheat
  # files) inside its own resources directory, which normally lives in the
  # read-only Nix store. Copy the extracted app into a writable per-user
  # cache dir once, then run from there instead - this mirrors what a
  # normal AppImage does when it self-extracts to /tmp on a machine without
  # FUSE, which is presumably how this launcher is meant to run.
  run = writeShellScript "${pname}-run" ''
    workdir="$HOME/.cache/${pname}/${version}"
    if [ ! -e "$workdir/.complete" ]; then
      rm -rf "$workdir"
      mkdir -p "$workdir"
      cp -r ${appimageContents}/. "$workdir"/
      chmod -R u+w "$workdir"
      touch "$workdir/.complete"
    fi
    exec "$workdir/AppRun" "$@"
  '';
in
appimageTools.wrapType2 {
  inherit pname version;
  src = appimage;

  # Add packages here if the launcher complains about a missing .so at
  # runtime - AppImages usually bundle most of what they need already.
  extraPkgs = pkgs: with pkgs; [ ];

  runScript = "${run}";

  meta = with lib; {
    description = "Launcher for the RPM RolePlay GTA San Andreas Multiplayer (SA-MP) server";
    homepage = "https://rpmserver.com";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    mainProgram = "rpmrp-launcher";
  };
}
