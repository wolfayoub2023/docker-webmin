FROM johanp/webmin

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DOMAIN=reachpulse.co
ENV HOSTNAME=mail.reachpulse.co

# Update & install only necessary dependencies
RUN apt update && apt upgrade -y && \
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
        dovecot-lmtpd \
        dovecot-mysql \
        libevent-dev \
        libpcre3-dev \
        automake \
        autoconf \
        libtool \
        git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure Postfix
RUN postconf -e "myhostname = $HOSTNAME" && \
    postconf -e "mydomain = $DOMAIN" && \
    postconf -e "myorigin = /etc/mailname" && \
    postconf -e "inet_interfaces = all" && \
    postconf -e "inet_protocols = all" && \
    postconf -e "mydestination = localhost, localhost.localdomain, $DOMAIN" && \
    postconf -e "mynetworks = 127.0.0.0/8" && \
    postconf -e "relay_domains =" && \
    postconf -e "home_mailbox = Maildir/"

# Configure Dovecot
RUN echo "mail_location = maildir:~/Maildir" >> /etc/dovecot/conf.d/10-mail.conf && \
    echo "protocols = imap lmtp" >> /etc/dovecot/dovecot.conf && \
    echo "ssl = no" >> /etc/dovecot/conf.d/10-ssl.conf

# Configure OpenDKIM
RUN opendkim-genkey -s mail -d $DOMAIN && \
    mkdir -p /etc/opendkim/keys/$DOMAIN && \
    mv mail.private /etc/opendkim/keys/$DOMAIN/mail.private && \
    mv mail.txt /etc/opendkim/keys/$DOMAIN/mail.txt && \
    chown opendkim:opendkim /etc/opendkim/keys/$DOMAIN/mail.private && \
    echo "Domain $DOMAIN" >> /etc/opendkim.conf && \
    echo "Selector mail" >> /etc/opendkim.conf && \
    echo "KeyFile /etc/opendkim/keys/$DOMAIN/mail.private" >> /etc/opendkim.conf

# Add trusted referrer to Webmin config
RUN echo "referers=reachpulse.co" >> /etc/webmin/config

# Expose required ports
EXPOSE 25 587 10000
