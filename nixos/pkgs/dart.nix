with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/9eade54db008c4a1eccee60c9080d00d47932918.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "dart";

    buildInputs = [
        pkgs.dart
        pkgs.flutter
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for dart.nix \n"

      MY_NAME=$(whoami)
    '';
}
