#!/usr/bin/env bash
shopt -s nullglob globstar
export DEBIAN_FRONTEND=noninteractive

# Usage:
# 1. docker build -t hardstone-nix .
# 2. docker run -it hardstone-nix
# 3. bash start.sh
# 4. docker-compose run my_nix_env


# TODO: setup ntp; https://help.ubuntu.com/community/UbuntuTime

THE_USER=$(whoami)

configure_timezone(){
    printf "\t\n\n 1.1 nix-installation pre-requistes: tzdata config A \n" 

    sudo rm -rf /tmp/*.txt

    echo "tzdata tzdata/Areas select Africa
    tzdata tzdata/Zones/Africa select Nairobi" | sudo tee /tmp/tzdata_preseed.txt
    debconf-set-selections /tmp/tzdata_preseed.txt

    sudo rm -rf /etc/timezone
    echo "Africa/Nairobi" | sudo tee /etc/timezone
    sudo ln -sf /usr/share/zoneinfo/Africa/Nairobi /etc/localtime

    sudo apt -y update;sudo apt -y install tzdata
    sudo dpkg-reconfigure --frontend noninteractive tzdata
}

install_nix_pre_requistes(){
    printf "\t\n\n 1. install nix-installation pre-requistes A \n"
    sudo apt -y update;sudo apt -y install sudo

    configure_timezone

    printf "\t\n\n 1.2 install nix-installation pre-requistes B \n" 
    sudo apt -y update; sudo apt -y install curl xz-utils
}
install_nix_pre_requistes

un_install_nix() {
    # see: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    printf "\t\n\n uninstall nix \n"
    sudo rm -rf /nix
}

upgrade_nix() {
    # see:
    # 1. https://nixos.org/manual/nix/stable/#ch-upgrading-nix
    # 2. https://nixos.org/manual/nix/stable/#sec-nix-channel
    printf "\t\n\n upgrade nix \n"
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-channel --update
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-channel --list

    # Channels are a way of distributing Nix software, but they are being phased out.
    # Even though they are still used by default,
    # it is recommended to avoid channels and <nixpkgs> by always setting NIX_PATH= to be empty.
    # see: https://nixos.org/guides/towards-reproducibility-pinning-nixpkgs.html#pinning-nixpkgs
}


create_nix_conf_file(){
    printf "\t\n\n create nix conf file(/etc/nix/nix.conf) \n"
    sudo rm -rf /etc/nix/nix.conf
    sudo mkdir -p /etc/nix/
    sudo cp etc.nix.nix.conf /etc/nix/nix.conf
}

install_nix() {
    NIX_PACKAGE_MANAGER_VERSION=2.3.10
    printf "\t\n\n 2. install Nix package manager version %s \n" "$NIX_PACKAGE_MANAGER_VERSION"
    # This is a single-user installation: https://nixos.org/manual/nix/stable/#sect-single-user-installation
    # meaning that /nix is owned by the invoking user. Do not run as root.
    # The script will invoke sudo to create /nix
    # The install script will modify the first writable file from amongst ~/.bash_profile, ~/.bash_login and ~/.profile to source ~/.nix-profile/etc/profile.d/nix.sh

    un_install_nix
    create_nix_conf_file

    sh <(curl -L https://releases.nixos.org/nix/nix-$NIX_PACKAGE_MANAGER_VERSION/install) --no-daemon
    . ~/.nix-profile/etc/profile.d/nix.sh # source a file

    upgrade_nix 
}
install_nix


setup_nix_ca_bundle(){
    printf "\t\n\n 3. setup Nix CA bundle \n"
    CURL_CA_BUNDLE=$(find /nix -name ca-bundle.crt |tail -n 1)
    # TODO: maybe this export should also be done in /etc/profile?
    export CURL_CA_BUNDLE=$CURL_CA_BUNDLE
}
setup_nix_ca_bundle


clear_stuff(){
    printf "\t\n\n 4. clear stuff \n"
    sudo apt -y clean
    sudo rm -rf /var/lib/apt/lists/*
    # The Nix store sometimes contains entries which are no longer useful.
    # garbage collect them
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-collect-garbage -d
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-store --optimise
    # ref: https://nixos.org/manual/nix/unstable/command-ref/nix-store.html
    /nix/var/nix/profiles/per-user/$THE_USER/profile/bin/nix-store --verify --repair
}
clear_stuff




uninstall_non_essential_apt_packages(){
    sudo rm -rf /tmp/*.txt

    # This are the packages that come with a clean install of ubuntu:20.04 docker image.
    # We should not remove this, else bad things can happen.
    # TODO: We should install a fresh ubuntu 20.04 in a laptop
    #       And then profile what packages it has by default, and see which ones we SHOULD add to this list.
    #       We do not want to remove essential packages, eg those that deal with WIFI etc
    #       Use `dpkg-query -Wf '${Package;-40}${Priority}\n' | sort -b -k2,2 -k1,1` to find out
    #       https://askubuntu.com/questions/79665/keep-only-essential-packages
    # REQUIRED_PACKAGES.
    # Found by running: `dpkg-query -Wf '${Package;-40}${Priority}\n' | sort -b -k2,2 -k1,1 | grep required |  awk '{print $1}'``
    echo "base-files
base-passwd
bash
bsdutils
coreutils
dash
debconf
debianutils
diffutils
dpkg
e2fsprogs
findutils
gcc-10-base
grep
gzip
hostname
init-system-helpers
libacl1
libattr1
libaudit-common
libaudit1
libbz2-1.0
libc-bin
libcap-ng0
libcom-err2
libcrypt1
libdb5.3
libdebconfclient0
libext2fs2
libgcrypt20
libgpg-error0
liblocale-gettext-perl
liblz4-1
libncurses6
libncursesw6
libpam-modules
libpam-modules-bin
libpam-runtime
libpcre2-8-0
libpcre3
libprocps8
libselinux1
libsemanage-common
libsemanage1
libsepol1
libss2
libtext-charwidth-perl
libtext-iconv-perl
libtext-wrapi18n-perl
libtinfo6
libzstd1
login
logsave
lsb-base
mawk
mount
ncurses-base
ncurses-bin
passwd
perl-base
procps
sed
sensible-utils
sysvinit-utils
tar
tzdata
util-linux
zlib1g"  >> /tmp/REQUIRED_PACKAGES.txt

    # IMPORTANT_PACKAGES.
    # Found by running: `dpkg-query -Wf '${Package;-40}${Priority}\n' | sort -b -k2,2 -k1,1 | grep important |  awk '{print $1}'`
    echo "adduser
apt
apt-utils
bsdmainutils
cpio
cron
debconf-i18n
dmidecode
fdisk
gpgv
groff-base
info
init
install-info
iproute2
iputils-ping
isc-dhcp-client
isc-dhcp-common
kmod
less
libcap2-bin
libmnl0
libreadline8
logrotate
man-db
nano
netbase
netcat-openbsd
readline-common
rsyslog
systemd
systemd-sysv
ubuntu-advantage-tools
ubuntu-keyring
udev
vim-common
vim-tiny" >> /tmp/IMPORTANT_PACKAGES.txt

    cat /tmp/REQUIRED_PACKAGES.txt /tmp/IMPORTANT_PACKAGES.txt > /tmp/BASE_PACKAGES.txt
    cat /tmp/BASE_PACKAGES.txt | sort >> /tmp/SORTED_BASE_PACKAGES.txt
    printf "\t\n\n base packages are; \n"
    cat /tmp/SORTED_BASE_PACKAGES.txt

    # install a dummy package so that there will always be a diff
    # between the currently installed packages & the base packages
    sudo apt -y update;sudo apt -y install cowsay

    ALL_CURRENTLY_INSTALLED_PACKAGES=$(dpkg --get-selections | awk '{print $1}')
    printf "\t\n\n all currently installed packages; \n"
    echo "$ALL_CURRENTLY_INSTALLED_PACKAGES"
    echo "$ALL_CURRENTLY_INSTALLED_PACKAGES" | tr " " "\n" >> /tmp/ALL_CURRENTLY_INSTALLED_PACKAGES.txt
    cat /tmp/ALL_CURRENTLY_INSTALLED_PACKAGES.txt | sort >> /tmp/SORTED_ALL_CURRENTLY_INSTALLED_PACKAGES.txt

    PACKAGES_TO_REMOVE=$(diff /tmp/SORTED_BASE_PACKAGES.txt /tmp/SORTED_ALL_CURRENTLY_INSTALLED_PACKAGES.txt | grep '>' | awk '{print $2}')
    printf "\t\n\n packages to be removed are; \n"
    echo "$PACKAGES_TO_REMOVE"

    sudo apt purge -y $PACKAGES_TO_REMOVE
    # sudo rm -rf /tmp/*.txt
}
uninstall_non_essential_apt_packages


# The main command for package management is nix-env.
# See: https://nixos.org/manual/nix/stable/#ch-basic-package-mgmt
