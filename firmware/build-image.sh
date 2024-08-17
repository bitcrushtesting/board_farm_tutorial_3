#!/bin/bash -e

# Copyright © 2024 Bitcrush Testing

# Check if an argument is given
if [ -z "$1" ]; then
    echo "Error: No install folder provided."
    echo "Usage: $0 <install_folder>"
    exit 1
fi

INSTALL_FOLDER="$1"
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

repo init -u git://git.toradex.com/toradex-manifest.git -b kirkstone-6.x.y -m tdxref/default.xml
repo sync

# shellcheck disable=SC1091
. export

# Adapt build/conf/local.conf 
sed -i 's/^#MACHINE ?= "verdin-imx8mp"/MACHINE ?= "verdin-imx8mp"/' $CONF_FILE
echo 'ACCEPT_FSL_EULA="1"' >> $CONF_FILE

# Start building
bitbake tdx-reference-minimal-image
