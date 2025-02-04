FROM pschatzmann/webmin

# Update repositories to Alpine v3.21
RUN echo "http://mirrors.aliyun.com/alpine/v3.21/main" > /etc/apk/repositories && \
    echo "http://mirrors.aliyun.com/alpine/v3.21/community" >> /etc/apk/repositories

# Install dependencies
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        alpine-sdk \
        openssl \
        libressl \
        opendkim \ 
        ca-certificates \
        curl \
        perl-net-ssleay \
        perl-io-socket-ssl \
        wget \
        postfix \
        spamassassin \
        dovecot \
        libressl \
        libevent-dev \
        pcre-dev \
        automake \
        autoconf \
        libtool \
        git

# Disable SSL in Webmin config
RUN sed -i 's/ssl=1/ssl=0/' /etc/webmin/miniserv.conf

# Add trusted referrer to Webmin config
RUN echo "referers=docker-webmin.onrender.com" >> /etc/webmin/config

# Expose Webmin default port (10000)
EXPOSE 10000

# Set up Postfix configuration for your domain reachpulse.co
RUN echo "myhostname = mail.reachpulse.co" >> /etc/postfix/main.cf && \
    echo "mydomain = reachpulse.co" >> /etc/postfix/main.cf && \
    echo "myorigin = /etc/mailname" >> /etc/postfix/main.cf && \
    echo "inet_interfaces = all" >> /etc/postfix/main.cf && \
    echo "inet_protocols = ipv4" >> /etc/postfix/main.cf

# Set up OpenDKIM configuration (if you need DKIM signing for your emails)
RUN opendkim-genkey -s mail -d reachpulse.co && \
    mv mail.private /etc/opendkim/keys/reachpulse.co.private && \
    mv mail.txt /etc/opendkim/keys/reachpulse.co.txt && \
    chown opendkim:opendkim /etc/opendkim/keys/reachpulse.co.private

# Expose SMTP ports (25, 587) for Postfix
EXPOSE 25 587

# Start Webmin and necessary services (Postfix, Dovecot, OpenDKIM)
CMD service postfix start && \
    service dovecot start && \
    service opendkim start && \
    /etc/webmin/miniserv.pl
