#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive

printf "\n\n install vscode dependencies \n"
apt -y install libxkbfile1
printf "\n\n  download vscode\n"
wget -nc --output-document=/tmp/vscode.deb "https://go.microsoft.com/fwlink/?LinkID=760868"
printf "\n\n  install vscode\n"
dpkg -i /tmp/vscode.deb

# on MacOs it is /Users/komuw/Library/Application\ Support/Code/User/settings.json
printf "\n\n  configure vscode user settings file\n"
mkdir -p /home/komuw/.config/Code/User
mkdir -p /home/komuw/.vscode
touch /home/komuw/.config/Code/User/settings.json
chown -R komuw:komuw /home/komuw/.config/Code/
chown -R komuw:komuw /home/komuw/.vscode
cp ../templates/vscode.j2 /home/komuw/.config/Code/User/settings.json

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
