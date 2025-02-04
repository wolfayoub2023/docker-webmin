FROM johanp/webmin

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
        build-essential \
        openssl \
        libssl-dev \
        opendkim \
        ca-certificates \
        curl \
        libnet-ssleay-perl \
        libio-socket-ssl-perl \
        wget \
        postfix \
        spamassassin \
        dovecot-core \
        dovecot-imapd \
        libevent-dev \
        libpcre3-dev \
        automake \
        autoconf \
        libtool \
        git

# Add trusted referrer to Webmin config
RUN echo "referers=docker-webmin.onrender.com" >> /etc/webmin/config

# Expose Webmin default port (10000)
EXPOSE 10000

# Expose SMTP ports (25, 587) for Postfix
EXPOSE 25 587
