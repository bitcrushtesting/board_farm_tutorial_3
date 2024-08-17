#!/bin/bash -e

# Copyright © 2024 Bitcrush Testing

DEPLOY_DIR="./pi-gen/deploy"
IMAGE_NAME="$(date +%F)-agent-node.img"
BOOT_MNT_DIR="/mnt/agent-node-boot"
ROOT_MNT_DIR="/mnt/agent-node-root"
TFTP_DIR="/srv/tftp/agent-node-boot"
NFS_DIR="/srv/nfs/agent-node-root"


USER_ID=$(id -u)
if [[ "$USER_ID" -eq 0 ]]; then
    echo "Must not run with sudo"
    exit 1
fi

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --image)
            IMAGE_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# Check if the image file was provided
if [[ -z "$IMAGE_FILE" ]]; then
    IMAGE_FILE="${DEPLOY_DIR}/${IMAGE_NAME}"
    echo "Using default image: ${IMAGE_FILE}"
fi

echo "Mount the boot partition of the image to ${BOOT_MNT_DIR}"
sudo umount -fq "${BOOT_MNT_DIR}" || true
sudo mkdir -p "${BOOT_MNT_DIR}"
BOOT_OFFSET=$(./get-offset.py "${IMAGE_FILE}" -p 1)
sudo mount -o loop,offset="${BOOT_OFFSET}" "${IMAGE_FILE}" "${BOOT_MNT_DIR}"
echo "Moving the boot files to the TFTP dir ${TFTP_DIR}"
sudo mkdir -p "${TFTP_DIR}"
sudo rm -rf "${TFTP_DIR}/*"
sudo chown "${USER}" "${TFTP_DIR}"
sudo cp -a "${BOOT_MNT_DIR}" "${TFTP_DIR}/"
sudo umount "${BOOT_MNT_DIR}"
sleep 1

echo "Mount the root partition of the image to ${ROOT_MNT_DIR}"
sudo umount -fq "${ROOT_MNT_DIR}" || true
sudo mkdir -p "${ROOT_MNT_DIR}"
ROOT_OFFSET=$(./get-offset.py "${IMAGE_FILE}" -p 2)
sudo mount -o loop,offset="$ROOT_OFFSET" "${IMAGE_FILE}" "${ROOT_MNT_DIR}"
echo "Moving the root files to the NFS dir ${NFS_DIR}"
sudo mkdir -p "$NFS_DIR"
sudo rm -rf "${NFS_DIR}/*"
sudo chown "$USER" "$NFS_DIR"
sudo cp -a "${ROOT_MNT_DIR}" "$NFS_DIR/"
sudo umount "${ROOT_MNT_DIR}"

echo "------ DONE ------"
