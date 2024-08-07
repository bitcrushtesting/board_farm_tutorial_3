#!/bin/bash -e

# Copyright © 2024 Bitcrush Testing

INSTALL_FOLDER="${HOME}/oe-core"
CONF_FILE="./conf/local.conf"

if [ ! -f /etc/debian_version ]; then
    echo "Only Debian-based systems supported."
    exit
fi

if [ -d "${INSTALL_FOLDER}" ]; then
    echo "Directory ${INSTALL_FOLDER} exists. Deleting it."
    rm -rf "$INSTALL_FOLDER"
fi

mkdir -p "$INSTALL_FOLDER"
cd "$INSTALL_FOLDER" || exit 

sudo apt install git chrpath lz4

if ! command -v repo >/dev/null 2>&1; then
    mkdir ~/bin
    export PATH=~/bin:$PATH
    curl https://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
fi

repo init -u git://git.toradex.com/toradex-manifest.git -b kirkstone-6.x.y -m tdxref/default.xml
repo sync

. export

# Adapt build/conf/local.conf 
sed -i 's/^#MACHINE ?= "verdin-imx8mp"/MACHINE ?= "verdin-imx8mp"/' $CONF_FILE
echo 'ACCEPT_FSL_EULA="1"' >> $CONF_FILE

# Start building
bitbake tdx-reference-minimal-image
