FROM johanp/webmin

# Add trusted referrer to Webmin config
RUN echo "referers=docker-webmin.onrender.com" >> /etc/webmin/config
