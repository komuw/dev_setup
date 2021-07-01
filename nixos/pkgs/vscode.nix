{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [];

  hooks = ''
    printf "\n\n running hooks for vscode.nix \n\n"

    MY_NAME=$(whoami)
    
    install_vscode(){
        printf "\n\n install vscode dependencies \n"

        rm -rf /tmp/vscode.deb
        sudo apt -y update
        sudo apt -y install libxkbfile1
        printf "\n\n  download vscode\n"
        wget -nc --output-document=/tmp/vscode.deb "https://go.microsoft.com/fwlink/?LinkID=760868"
        sudo dpkg -i /tmp/vscode.deb
    }
    install_vscode

    add_vscode_cofig(){
        # on MacOs it is /Users/$MY_NAME/Library/Application\ Support/Code/User/settings.json
        printf "\n\n  configure vscode user settings file\n"
        mkdir -p /home/$MY_NAME/.config/Code/User
        mkdir -p /home/$MY_NAME/.vscode
        touch /home/$MY_NAME/.config/Code/User/settings.json
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.config/Code/
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/.vscode
        cp ../templates/vscode.j2 /home/$MY_NAME/.config/Code/User/settings.json
    }
    add_vscode_cofig

    install_vscode_extensions(){
        printf "\n\n  install vscode extensions\n"
        code --user-data-dir='.' --install-extension ms-python.python
        code --user-data-dir='.' --install-extension ms-python.vscode-pylance
        code --user-data-dir='.' --install-extension dart-code.dart-code
        code --user-data-dir='.' --install-extension dart-code.flutter
        code --user-data-dir='.' --install-extension donaldtone.auto-open-markdown-preview-single
        code --user-data-dir='.' --install-extension golang.go
        code --user-data-dir='.' --install-extension ms-azuretools.vscode-docker
        code --user-data-dir='.' --install-extension hashicorp.terraform
        # code --user-data-dir='.' --install-extension ms-vscode.cpptools
        code --list-extensions
    }
    install_vscode_extensions

  '';
}


