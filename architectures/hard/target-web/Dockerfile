FROM php:7.4-apache

# 1. Installation des dépendances
# On ajoute openssh-server pour permettre le pivot plus tard
RUN apt-get update && apt-get install -y \
    curl \
    netcat \
    iproute2 \
    netcat-traditional \
    nmap \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuration SSH (Pour le pivot futur)
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN update-alternatives --set nc /bin/nc.traditional

RUN echo "GatewayPorts yes" >> /etc/ssh/sshd_config

# 3. Configuration du site web vulnérable
COPY src/ /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# 4. CRÉATION DE LA FAILLE PRIVILEGE ESCALATION (ROOT)
# SUID sur find : permet à l'attaquant de devenir root facilement
RUN chmod u+s /usr/bin/find

# 5. Le Flag Root
RUN echo "FLAG{HARD_WEB_SSRF_SUID_ROOT}" > /root/root_flag.txt
RUN chmod 600 /root/root_flag.txt

# 6. Script de démarrage
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# On expose HTTP (80) et SSH (22) pour le pivot interne
EXPOSE 80 22

ENTRYPOINT ["/entrypoint.sh"]
