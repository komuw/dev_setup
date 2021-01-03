#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -eo pipefail
fi
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive

# START
# docker run -it ubuntu:20.04 bash


# TODO: setup ntp; https://help.ubuntu.com/community/UbuntuTime



install_nix_pre_requistes(){
    printf "\n\n 1. install nix-installation pre-requistes A \n" 
    apt -y update;apt -y install tzdata sudo

    printf "\n\n 1.1 nix-installation pre-requistes: tzdata config A \n" 
    echo "tzdata tzdata/Areas select Africa
    tzdata tzdata/Zones/Africa select Nairobi" >> /tmp/tzdata_preseed.txt
    debconf-set-selections /tmp/tzdata_preseed.txt
    rm -rf /etc/timezone; echo "Africa/Nairobi" >> /etc/timezone
    sudo dpkg-reconfigure --frontend noninteractive tzdata

    printf "\n\n 1.2 install nix-installation pre-requistes B \n" 
    apt -y update;apt -y install curl xz-utils
}
install_nix_pre_requistes

un_install_nix() {
    # see: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    printf "\n\n uninstall nix \n"
    rm -rf /nix
}

upgrade_nix() {
    # see: https://nixos.org/manual/nix/stable/#ch-upgrading-nix
    printf "\n\n upgrade nix \n"
    /nix/var/nix/profiles/default/bin/nix-channel --update
}


# TODO: come up with my own nix config file(/etc/nix/nix.conf)
# https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
install_nix() {
    NIX_PACKAGE_MANAGER_VERSION=2.3.10
    printf "\n\n 2. install Nix package manager version $NIX_PACKAGE_MANAGER_VERSION \n"
    # This is a single-user installation: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    # meaning that /nix is owned by the invoking user. Do not run as root.
    # The script will invoke sudo to create /nix
    # The install script will modify the first writable file from amongst ~/.bash_profile, ~/.bash_login and ~/.profile to source ~/.nix-profile/etc/profile.d/nix.sh
    un_install_nix
    rm -rf /etc/nix/nix.conf; mkdir -p /etc/nix/; echo "build-users-group =" >> /etc/nix/nix.conf # see: https://github.com/NixOS/nix/issues/697
    sh <(curl -L https://releases.nixos.org/nix/nix-$NIX_PACKAGE_MANAGER_VERSION/install) --no-daemon
    . ~/.nix-profile/etc/profile.d/nix.sh # source a file
    upgrade_nix 
}
install_nix


setup_nix_ca_bundle(){
    printf "\n\n 3. setup Nix CA bundle \n"
    CURL_CA_BUNDLE=$(find /nix -name ca-bundle.crt |tail -n 1)
    # TODO: maybe this export should also be done in /etc/profile?
    export CURL_CA_BUNDLE=$CURL_CA_BUNDLE
}
setup_nix_ca_bundle


clear_stuff(){
    printf "\n\n 4. clear stuff \n"
    apt -y clean
    rm -rf /var/lib/apt/lists/*
    # The Nix store sometimes contains entries which are no longer useful.
    # garbage collect them
    /nix/var/nix/profiles/default/bin/nix-collect-garbage -d
    /nix/var/nix/profiles/default/bin/nix-store --optimise
    # ref: https://nixos.org/manual/nix/unstable/command-ref/nix-store.html
    /nix/var/nix/profiles/default/bin/nix-store --verify --repair
}
clear_stuff


uninstall_non_essential_apt_packages(){
    rm -rf /tmp/*.txt

    # This are the packages that come with a clean install of ubuntu:20.04 docker image.
    # We should not remove this, else bad things can happen.
    echo "adduser
apt
base-files
base-passwd
bash
bsdutils
bzip2
ca-certificates
coreutils
curl
dash
debconf
debianutils
diffutils
dpkg
e2fsprogs
fdisk
findutils
gcc-10-base:amd64
gpgv
grep
gzip
hostname
init-system-helpers
krb5-locales
libacl1:amd64
libapt-pkg6.0:amd64
libasn1-8-heimdal:amd64
libattr1:amd64
libaudit-common
libaudit1:amd64
libblkid1:amd64
libbrotli1:amd64
libbz2-1.0:amd64
libc-bin
libc6:amd64
libcap-ng0:amd64
libcom-err2:amd64
libcrypt1:amd64
libcurl4:amd64
libdb5.3:amd64
libdebconfclient0:amd64
libext2fs2:amd64
libfdisk1:amd64
libffi7:amd64
libgcc-s1:amd64
libgcrypt20:amd64
libgmp10:amd64
libgnutls30:amd64
libgpg-error0:amd64
libgssapi-krb5-2:amd64
libgssapi3-heimdal:amd64
libhcrypto4-heimdal:amd64
libheimbase1-heimdal:amd64
libheimntlm0-heimdal:amd64
libhogweed5:amd64
libhx509-5-heimdal:amd64
libidn2-0:amd64
libk5crypto3:amd64
libkeyutils1:amd64
libkrb5-26-heimdal:amd64
libkrb5-3:amd64
libkrb5support0:amd64
libldap-2.4-2:amd64
libldap-common
liblz4-1:amd64
liblzma5:amd64
libmount1:amd64
libncurses6:amd64
libncursesw6:amd64
libnettle7:amd64
libnghttp2-14:amd64
libp11-kit0:amd64
libpam-modules:amd64
libpam-modules-bin
libpam-runtime
libpam0g:amd64
libpcre2-8-0:amd64
libpcre3:amd64
libprocps8:amd64
libpsl5:amd64
libroken18-heimdal:amd64
librtmp1:amd64
libsasl2-2:amd64
libsasl2-modules:amd64
libsasl2-modules-db:amd64
libseccomp2:amd64
libselinux1:amd64
libsemanage-common
libsemanage1:amd64
libsepol1:amd64
libsmartcols1:amd64
libsqlite3-0:amd64
libss2:amd64
libssh-4:amd64
libssl1.1:amd64
libstdc++6:amd64
libsystemd0:amd64
libtasn1-6:amd64
libtinfo6:amd64
libudev1:amd64
libunistring2:amd64
libuuid1:amd64
libwind0-heimdal:amd64
libzstd1:amd64
login
logsave
lsb-base
mawk
mount
ncurses-base
ncurses-bin
openssl
passwd
perl-base
procps
publicsuffix
sed
sensible-utils
sudo
sysvinit-utils
tar
tzdata
ubuntu-keyring
util-linux
xz-utils
zlib1g:amd64" >> /tmp/BASE_PACKAGES.txt
    cat /tmp/BASE_PACKAGES.txt | sort >> /tmp/SORTED_BASE_PACKAGES.txt
    printf "\n\n base packages are; \n"
    cat /tmp/SORTED_BASE_PACKAGES.txt

    # install a dummy package so that there will always be a diff
    # between the currently installed packages & the base packages
    apt -y update;apt -y install cowsay

    ALL_CURRENTLY_INSTALLED_PACKAGES=`dpkg --get-selections | awk '{print $1}'`
    printf "\n\n all currently installed packages; \n"
    echo $ALL_CURRENTLY_INSTALLED_PACKAGES
    echo $ALL_CURRENTLY_INSTALLED_PACKAGES | tr " " "\n" >> /tmp/ALL_CURRENTLY_INSTALLED_PACKAGES.txt
    cat /tmp/ALL_CURRENTLY_INSTALLED_PACKAGES.txt | sort >> /tmp/SORTED_ALL_CURRENTLY_INSTALLED_PACKAGES.txt

    PACKAGES_TO_REMOVE=`diff /tmp/SORTED_BASE_PACKAGES.txt /tmp/SORTED_ALL_CURRENTLY_INSTALLED_PACKAGES.txt | grep '>' | awk '{print $2}'`
    printf "\n\n packages to be removed are; \n"
    echo $PACKAGES_TO_REMOVE

    apt purge -y $PACKAGES_TO_REMOVE
    rm -rf /tmp/*.txt
}
uninstall_non_essential_apt_packages


