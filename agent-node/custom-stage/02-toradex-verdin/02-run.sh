#!/bin/bash -e

mkdir -p "${ROOTFS_DIR}/etc/minicom"
cp files/minirc.verdin "${ROOTFS_DIR}/etc/minicom/"
