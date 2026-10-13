# Orca — "The AI Orchestrator for 100x builders" (https://github.com/stablyai/orca)
#
# Upstream ships Linux only as an AppImage, so this wraps it in an FHS
# environment with appimageTools.
#
# To upgrade: bump `version`, set `hash` to lib.fakeHash, rebuild, and copy the
# correct hash out of the error message. Or prefetch it directly:
#   nix-prefetch-url https://github.com/stablyai/orca/releases/download/v<VER>/orca-linux.AppImage
{ lib, appimageTools, fetchurl, makeDesktopItem }:

let
  pname = "orca-ide";
  version = "1.4.224";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-sf6RAtmH012X622cJ0qT2elRqtvoZPwiUaMVAj9gx0Y=";
  };

  # Used only to lift the bundled icons out of the image.
  appimageContents = appimageTools.extractType2 { inherit pname version src; };

  # The bundled .desktop entry points at `AppRun`, which does not exist outside
  # the AppImage, so declare our own pointing at the wrapper on PATH.
  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Orca";
    comment = "Next-gen IDE for parallel agentic development";
    exec = "${pname} %U";
    icon = pname;
    categories = [ "Development" ];
    startupWMClass = "orca";
    mimeTypes = [
      "text/markdown"
      "text/csv"
      "text/tab-separated-values"
      "x-scheme-handler/orca" # deep links from the Orca mobile companion
    ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Beyond the Electron/Chromium deps appimageTools already provides:
  #   libsecret  - Electron keytar, for storing agent API keys in the keyring
  #   git        - Orca drives one git worktree per agent
  extraPkgs = pkgs: with pkgs; [ libsecret git ];

  extraInstallCommands = ''
    # Convenience alias; `orca-ide` stays the canonical name so this never
    # fights the GNOME `orca` screen reader if that ever gets installed.
    ln -s $out/bin/${pname} $out/bin/orca

    install -Dm444 ${desktopItem}/share/applications/${pname}.desktop \
      -t $out/share/applications

    for size in 16 24 32 48 64 128 256 512; do
      install -Dm444 \
        ${appimageContents}/usr/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png \
        $out/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png
    done
  '';

  meta = {
    description = "AI orchestrator for running multiple coding agents side-by-side";
    homepage = "https://onorca.dev";
    downloadPage = "https://github.com/stablyai/orca/releases";
    license = lib.licenses.unfree; # closed-source binary release
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
