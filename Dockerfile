FROM pschatzmann/webmin


# Disable SSL in Webmin config
RUN sed -i 's/ssl=1/ssl=0/' /etc/webmin/miniserv.conf

# Add trusted referrer to Webmin config
RUN echo "referers=docker-webmin.onrender.com" >> /etc/webmin/config

# Expose Webmin default port (10000)
EXPOSE 10000
