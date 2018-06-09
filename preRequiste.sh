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


printf "\n\n starting setup/provisioning....\n"
printf "\n\n install pre-requiste stuff reequired by the other scripts. \nthe other scripts should be able to run in parallel....\n"
apt-get -y update
apt-get -y install gcc \
                    build-essential \
                    libssl-dev \
                    libffi-dev \
                    python-dev \
                    software-properties-common \
                    curl \
                    wget \
                    git
curl https://bootstrap.pypa.io/get-pip.py | python - 'pip==9.0.3' # see:: https://github.com/pypa/pip/issues/5240
pip install --ignore-installed -U pip
apt-get -y update