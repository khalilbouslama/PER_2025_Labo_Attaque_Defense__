FROM php:7.4-apache

# 1. Installation des outils (Ajout de openssh-server)
RUN apt-get update && apt-get install -y \
    sudo \
    gcc \
    netcat-traditional \
    curl \
    gnupg \
    apt-transport-https \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 2. Ajout du dépôt Wazuh
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add - && \
    echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list

# 3. Installation de l'agent Wazuh (VERSION 4.9.0 pour matcher le manager)
RUN apt-get update && apt-get install -y \
    wazuh-agent=4.9.0-1 \
    && rm -rf /var/lib/apt/lists/*


# 4. Configuration de la faille LD_PRELOAD
RUN echo "www-data ALL=(root) NOPASSWD: /usr/bin/gzip" >> /etc/sudoers
RUN echo 'Defaults env_keep += "LD_PRELOAD"' >> /etc/sudoers

# 5. CONFIGURATION SSH (POUR LE PIVOT)
# On autorise root à se connecter
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# On définit le mot de passe root à "toor"
RUN echo 'root:toor' | chpasswd

# 6. FIX GZIP (Lien symbolique permanent)
RUN ln -s /bin/gzip /usr/bin/gzip

# 7. Copie du site web vulnérable
COPY src/ /var/www/html/
RUN mkdir /var/www/html/uploads && \
    chown -R www-data:www-data /var/www/html && \
    chmod 777 /var/www/html/uploads

# 8. Configuration IP temporaire
RUN echo "WAZUH_MANAGER_IP=172.17.0.1" > /IP_WAZUH

# 9. Les Flags
RUN echo "FLAG{MEDIUM_GATEWAY_PWNED}" > /root/flag.txt && chmod 400 /root/flag.txt
RUN echo "FLAG{MEDIUM_WEB_LD_PRELOAD_ROOT}" > /root/root_flag.txt && chmod 600 /root/root_flag.txt

# 10. Script de démarrage
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Fix Apache logs pour Wazuh (créer vrais fichiers au lieu de stdout)
RUN rm /var/log/apache2/access.log /var/log/apache2/error.log && \
    touch /var/log/apache2/access.log /var/log/apache2/error.log && \
    chown www-data:www-data /var/log/apache2/*.log

# 11. Bash logging SANS rsyslog (trap DEBUG - log AVANT exécution)
RUN touch /var/log/commands.log && chmod 666 /var/log/commands.log
RUN echo 'trap '\''echo "$(date "+%b %d %H:%M:%S") BASH_CMD:$(whoami):$(pwd):$(HISTTIMEFORMAT= history 1 | sed "s/^[ ]*[0-9]\+[ ]*//")" >> /var/log/commands.log'\'' DEBUG' >> /etc/bash.bashrc

EXPOSE 80 22
ENTRYPOINT ["/entrypoint.sh"]
