FROM johanp/webmin

# Set environment variables
ENV DOMAIN=reachpulse.co

# Update and install necessary packages
RUN apt update && \
    apt install -y --no-install-recommends \
        openssl \
        opendkim \
        opendkim-tools \
        postfix \
        dovecot-core \
        dovecot-imapd \
        ca-certificates \
        curl \
        spamassassin && \
    rm -rf /var/lib/apt/lists/*  # Reduce image size

# Configure Postfix
RUN postconf -e "myhostname = mail.$DOMAIN" && \
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
RUN mkdir -p /etc/opendkim/keys/$DOMAIN && \
    opendkim-genkey -b 2048 -d $DOMAIN -s mail -D /etc/opendkim/keys/$DOMAIN/ && \
    chown opendkim:opendkim /etc/opendkim/keys/$DOMAIN/mail.private && \
    echo "Domain $DOMAIN" >> /etc/opendkim.conf && \
    echo "Selector mail" >> /etc/opendkim.conf && \
    echo "KeyFile /etc/opendkim/keys/$DOMAIN/mail.private" >> /etc/opendkim.conf

# Add trusted referrer to Webmin
RUN echo "referers=docker-webmin.onrender.com" >> /etc/webmin/config

# Expose necessary ports
EXPOSE 25 587 10000
