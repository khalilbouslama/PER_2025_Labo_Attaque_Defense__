
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# 1. Installation Apache + Outils
RUN apt-get update && apt-get install -y \
    curl gnupg apt-transport-https lsb-release \
    apache2 openssh-server cron iputils-ping nano rsyslog \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation Wazuh Agent
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
RUN apt-get update && WAZUH_MANAGER="wazuh.manager" WAZUH_AGENT_VERSION="4.9.0-1" apt-get install -y wazuh-agent=4.9.0-1

# 3. Création de l'utilisateur 'webuser'
RUN useradd -m -s /bin/bash webuser && echo "webuser:webpass123" | chpasswd

# 4. CONFIGURATION SSH ET CLÉS (LA CORRECTION EST ICI)
# On crée le dossier SSH
RUN mkdir -p /home/webuser/.ssh

# On active l'authentification par clé publique dans la config du serveur
RUN mkdir /var/run/sshd
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
# Activer les logs SSH
RUN sed -i 's/#SyslogFacility AUTH/SyslogFacility AUTH/' /etc/ssh/sshd_config && \
    sed -i 's/#LogLevel INFO/LogLevel INFO/' /etc/ssh/sshd_config

# Format traditionnel rsyslog
RUN echo '$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat' > /etc/rsyslog.d/traditional.conf

# On génère les clés et on les place
RUN ssh-keygen -t rsa -f /home/webuser/.ssh/id_rsa -q -N "cassandra" \
    && cp /home/webuser/.ssh/id_rsa.pub /home/webuser/.ssh/authorized_keys \
    && cp /home/webuser/.ssh/id_rsa /var/www/html/backup_key.pem

# === LE CORRECTIF CRITIQUE ===
# On donne TOUT le dossier .ssh à l'utilisateur (avant c'était à root)
RUN chown -R webuser:webuser /home/webuser/.ssh
# On met les permissions strictes (700 pour dossier, 600 pour fichier)
RUN chmod 700 /home/webuser/.ssh
RUN chmod 600 /home/webuser/.ssh/authorized_keys
# On rend la clé volée lisible sur le web
RUN chmod 644 /var/www/html/backup_key.pem

# 5. La Faille 1 : Directory Listing
RUN rm /var/www/html/index.html

# 6. La Faille 2 : Cron Job Root
RUN echo "#!/bin/bash\n# Maintenance script\necho 'Cleaning up...'" > /opt/cleanup.sh
RUN chmod 777 /opt/cleanup.sh
RUN echo "* * * * * root /opt/cleanup.sh" >> /etc/crontab

# 7. Config Wazuh
RUN sed -i '/<\/ossec_config>/i \
  <localfile>\n\
    <location>/var/log/apache2/access.log</location>\n\
    <log_format>apache</log_format>\n\
  </localfile>\n\
  <localfile>\n\
    <location>/var/log/auth.log</location>\n\
    <log_format>syslog</log_format>\n\
  </localfile>' /var/ossec/etc/ossec.conf

# 7. LE FLAG FINAL (ROOT ONLY)
# On crée le fichier chez root (inaccessible par défaut)
RUN echo "FLAG{APACHE_CRON_PRIVESC_MASTER}" > /root/root_flag.txt

# On verrouille le fichier (Seul root peut lire)
RUN chmod 600 /root/root_flag.txt

# 8. Démarrage
# Fix rsyslog : format traditionnel pour Wazuh
COPY 50-default.conf /etc/rsyslog.d/50-default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 80 22
ENTRYPOINT ["/entrypoint.sh"]

