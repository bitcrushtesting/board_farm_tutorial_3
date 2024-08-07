#!/bin/bash -e

# Copyright © 2024 Bitcrush Testing

DEPLOY_DIR="./pi-gen/deploy"
IMAGE_DIR="${HOME}/agent-node-image"
IMAGE_NAME="$(date +%F)-agent-node.img"
BOOT_MNT_DIR="/mnt/agent-node-boot"
ROOT_MNT_DIR="/mnt/agent-node-root"
TFTP_DIR="/srv/tftp/agent-node-boot"
NFS_DIR="/srv/nfs/agent-node-root"

echo "Moving the image to ${IMAGE_DIR}"
mkdir -p "${IMAGE_DIR}"
mv "${DEPLOY_DIR}/${IMAGE_NAME}" "${IMAGE_DIR}"

echo "Create a mount point for the boot and root partition"
mkdir -p "${BOOT_MNT_DIR}"
mkdir -p "${ROOT_MNT_DIR}"

BOOT_OFFSET=$(./get-offset.py "${IMAGE_NAME}" -p 1)
ROOT_OFFSET=$(./get-offset.py "${IMAGE_NAME}" -p 2)

echo "Mount the boot partition of the image to ${BOOT_MNT_DIR}"
sudo mount -o loop,offset="$BOOT_OFFSET" "${DEPLOY_DIR}/${IMAGE_NAME}" "${BOOT_MNT_DIR}"

echo "Mount the root partition of the image to ${ROOT_MNT_DIR}"
sudo mount -o loop,offset="$ROOT_OFFSET" "${DEPLOY_DIR}/${IMAGE_NAME}" "${ROOT_MNT_DIR}"

echo "Moving the boot files to the TFTP dir ${TFTP_DIR}"
sudo mkdir -p "$TFTP_DIR"
cp -r "${BOOT_MNT_DIR}/" "$TFTP_DIR/"
sudo unmount "${BOOT_MNT_DIR}"

echo "Moving the root files to the NFS dir ${NFS_DIR}"
sudo mkdir -p $NFS_DIR
cp -r "${ROOT_MNT_DIR}/" "$NFS_DIR/"
sudo unmount "${ROOT_MNT_DIR}"


echo "------ DONE ------"
