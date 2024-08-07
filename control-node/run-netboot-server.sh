#!/bin/bash

# Copyright © 2024 Bitcrush Testing

IMAGE_NAME="rpi-netboot-server"
CONTAINER_NAME="rpi-netboot-server"
TFTP_DIR="/srv/tftp/agent-node-boot"
NFS_DIR="/srv/nfs/agent-node-root"

# Check if the Docker image exists
if [[ "$(docker images -q "$IMAGE_NAME" 2> /dev/null)" == "" ]]; then
    echo "Docker image '$IMAGE_NAME' not found."
    read -rp "Do you want to build the Docker image? (y/n): " build_image

    if [[ "$build_image" == "y" || "$build_image" == "Y" ]]; then
        echo "Building Docker image '$IMAGE_NAME'..."
        if ! docker build -t $IMAGE_NAME .
        then
            echo "Failed to build the Docker image."
            exit 1
        fi
    else
        echo "Docker image not built. Exiting."
        exit 0
    fi
else
    echo "Docker image '$IMAGE_NAME' is already available."
fi

# Check if the container is already running
if [[ "$(docker ps -q -f name=$CONTAINER_NAME)" ]]; then
    echo "Container '$CONTAINER_NAME' is already running."
else
    echo "Running the Docker container..."
    
    # Run the container with necessary options
    if ! docker run -d \
        --name "$CONTAINER_NAME" \
        --privileged \
        -p 69:69/udp \
        -p 2049:2049/tcp \
        -v "$TFTP_DIR:/tftpboot" \
        -v "$NFS_DIR:/nfsboot" \
        "$IMAGE_NAME"
    then
        echo "Failed to run the Docker container."
        exit 1
    fi

    echo "Docker container '$CONTAINER_NAME' is now running."
fi
