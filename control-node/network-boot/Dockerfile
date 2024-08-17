# Use a lightweight base image
FROM debian:bullseye-slim

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tftp-hpa \
    nfs-kernel-server \
    inetutils-inetd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /tftpboot /nfsboot

# Configure TFTP server
RUN echo "TFTP_DIRECTORY=\"/tftpboot\"" > /etc/default/tftpd-hpa && \
    echo "TFTP_OPTIONS=\"--secure --create\"" >> /etc/default/tftpd-hpa

# Configure NFS server
RUN echo "/nfsboot *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

# Copy a startup script into the container
COPY start-services.sh /usr/local/bin/start-services.sh
RUN chmod +x /usr/local/bin/start-services.sh

# Expose the necessary ports
EXPOSE 69/udp 2049/tcp

# Start both services
CMD ["/usr/local/bin/start-services.sh"]

