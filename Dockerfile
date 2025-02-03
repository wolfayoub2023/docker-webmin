# Use a lightweight base image
FROM ubuntu:20.04

# Environment variables to avoid prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update \
    && apt-get install -y wget apt-transport-https software-properties-common gnupg \
    && wget -O webmin-setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repos.sh \
    && sh webmin-setup-repos.sh \
    && apt-get install -y webmin --install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Expose Webmin port
EXPOSE 10000

# Start Webmin
CMD ["/etc/webmin/start"]
