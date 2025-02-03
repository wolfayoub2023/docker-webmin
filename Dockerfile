# Start with the Alpine base image
FROM alpine:latest

# Set the maintainer label
LABEL maintainer="lyderic <lyderic@lyderic.com>"

# Arguments for SSH user and password
ARG sshuser=foo
ARG sshpassword=bar

# Update Alpine and install necessary packages
RUN apk update && apk upgrade && \
    apk add --no-cache openssh bash

# Generate SSH host keys
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t dsa -N "" -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -t ecdsa -N "" -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key

# Create the SSH user and set the password
RUN adduser -D $sshuser && \
    echo "$sshuser:$sshpassword" | chpasswd

# Configure SSH to allow remote connections
RUN echo "AllowUsers $sshuser" >> /etc/ssh/sshd_config

# Start the SSH daemon and system services
RUN echo '::sysinit:/sbin/syslogd' > /etc/inittab && \
    echo '::sysinit:/usr/sbin/sshd' >> /etc/inittab

# Set the default entrypoint to run the init process
ENTRYPOINT ["/sbin/init"]

# Expose SSH port
EXPOSE 22
