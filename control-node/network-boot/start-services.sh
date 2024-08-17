#!/bin/bash

# Start the TFTP server
service tftpd-hpa start

# Start the NFS server
service nfs-kernel-server start

# Keep the container running
tail -f /dev/null
