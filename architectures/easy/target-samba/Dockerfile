FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# 1. Installation des paquets
RUN apt-get update && apt-get install -y \
    curl gnupg apt-transport-https lsb-release \
    samba iputils-ping rsyslog \
    openssh-server nano iptables \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation Agent Wazuh
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
RUN apt-get update && WAZUH_MANAGER="wazuh.manager" WAZUH_AGENT_VERSION="4.9.0-1" apt-get install -y wazuh-agent=4.9.0-1

# 3. Configuration SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
# Activer les logs SSH vers syslog
RUN sed -i 's/#SyslogFacility AUTH/SyslogFacility AUTH/' /etc/ssh/sshd_config && \
    sed -i 's/#LogLevel INFO/LogLevel INFO/' /etc/ssh/sshd_config

# Format traditionnel rsyslog (compatible Wazuh)
RUN echo '$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat' > /etc/rsyslog.d/traditional.conf

# 4. Configuration de l'Attaque
# A. Création de l'utilisateur cible 'sambauser'
RUN useradd -m -s /bin/bash sambauser

# Mot de passe SYSTEME (pour SSH)
RUN echo "sambauser:princess1" | chpasswd

# B. Mot de passe Samba (Pour le partage)
RUN (echo "princess1"; echo "princess1") | smbpasswd -a -s sambauser

# C. Dossier PUBLIC (L'indice)
RUN mkdir -p /srv/public
RUN chmod 777 /srv/public
RUN echo "Note pour l'admin : Le compte 'sambauser' est prêt. Login SSH activé." > /srv/public/note_service.txt

# D. Dossier PRIVÉ (Premier flag, niveau facile)
RUN mkdir -p /srv/private
RUN echo "FLAG{SAMBA_USER_ACCESS}" > /srv/private/flag.txt
RUN chown -R sambauser:sambauser /srv/private && chmod 700 /srv/private

# --- AJOUT SCÉNARIO ROOT ---

# E. LE FLAG FINAL (ROOT ONLY - Niveau Difficile)
# On crée le fichier chez root
RUN echo "FLAG{SAMBA_SUID_FIND_EXPLOIT}" > /root/root_flag.txt
# On le verrouille (seul root peut le lire)
RUN chmod 600 /root/root_flag.txt

# F. LA FAILLE D'ESCALADE (Privesc via SUID)
# On donne le droit SUID à la commande 'find'.
# Cela permettra à sambauser d'exécuter des commandes en tant que root via find.
RUN chmod u+s /usr/bin/find

# --- FIN AJOUT ---

# 5. Injection du fichier de conf Samba
COPY smb.conf /etc/samba/smb.conf

# 6. Config Wazuh
RUN sed -i '/<\/ossec_config>/i \
  <localfile>\n\
    <location>/var/log/samba/log.smbd</location>\n\
    <log_format>syslog</log_format>\n\
  </localfile>\n\
  <localfile>\n\
    <location>/var/log/auth.log</location>\n\
    <log_format>syslog</log_format>\n\
  </localfile>' /var/ossec/etc/ossec.conf

# 7. Démarrage
# Fix rsyslog : format traditionnel pour Wazuh
COPY 50-default.conf /etc/rsyslog.d/50-default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 22 139 445
ENTRYPOINT ["/entrypoint.sh"]
