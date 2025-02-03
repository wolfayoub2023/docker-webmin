# Use the official Alpine image as the base image
FROM alpine:latest

# Update and install necessary packages: openssh and bash
RUN apk update && apk upgrade && \
    apk add --no-cache openssh bash

# Generate SSH host keys (removed DSA key generation)
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t ecdsa -N "" -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key

# Set up the container to start SSH server
CMD ["/usr/sbin/sshd", "-D"]
