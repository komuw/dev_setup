with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/01d4e58f598bcaf02e5a92a67a98afccecc94b0c.tar.gz") {});

let

in stdenv.mkDerivation {
    name = "tools";

    buildInputs = [
        pkgs.youtube-dl
        pkgs.asciinema
        pkgs.httpie
        # https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html
        pkgs.awscli
        pkgs.awscli2
        pkgs.bat
        pkgs.google-chrome # unfree
        pkgs.skypeforlinux # unfree
        pkgs.ripgrep
        pkgs.ripgrep-all
        pkgs.rr
        pkgs.unixtools.netstat
        pkgs.fzf
        pkgs.delta # https://github.com/dandavison/delta

        # For some reason, zoom installed via nix is not working.
        # So we install it manually in `nixos/start.sh`.
        # TODO: remove this once we get zoom working on nix.
        # pkgs.zoom-us # unfree

        # WE HAVENT FOUND THESE:
        # pip
        # sewer
    ];

    shellHook = ''
        # set -e # fail if any command fails
        # do not use `set -e` which causes commands to fail.
        # because it causes `nix-shell` to also exit if a command fails when running in the eventual shell

      printf "\n running hooks for tools.nix \n"

      MY_NAME=$(whoami)

      install_zoom(){
          # For some reason, zoom installed via nix is not working.
          # So we install it manually.
          # TODO: remove this once we get zoom working on nix.

          zoom_file="/usr/bin/zoom"
          if [ -f "$zoom_file" ]; then
              # exists
              echo -n ""
          else
              sudo apt -y update
              # install zoom dependencies
              sudo apt-get -y install libgl1-mesa-glx \
                                      libegl1-mesa \
                                      libxcb-xtest0 \
                                      libxcb-xinerama0

              rm -rf /tmp/zoom_amd64.deb
              wget -nc --output-document=/tmp/zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb
              sudo dpkg -i /tmp/zoom_amd64.deb
          fi
      }
      install_zoom

    '';
}
