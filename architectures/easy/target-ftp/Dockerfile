FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# 1. Installation des paquets (FTP + Outils)
RUN apt-get update && apt-get install -y \
    curl gnupg apt-transport-https lsb-release \
    vsftpd iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation de l'Agent Wazuh
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
RUN apt-get update && WAZUH_MANAGER="wazuh.manager" WAZUH_AGENT_VERSION="4.9.0-1" apt-get install -y wazuh-agent=4.9.0-1

# 3. Configuration de la Faille FTP (Anonymous Allowed)
# On crée le dossier pour l'utilisateur anonyme
RUN mkdir -p /var/ftp/pub
RUN echo "FLAG{FTP_ANONYMOUS_SUCCESS}" > /var/ftp/pub/flag.txt
RUN chmod 755 /var/ftp/pub

# On configure vsftpd pour autoriser l'anonyme et les logs
RUN echo "listen=YES" > /etc/vsftpd.conf && \
    echo "listen_ipv6=NO" >> /etc/vsftpd.conf && \
    echo "anonymous_enable=YES" >> /etc/vsftpd.conf && \
    echo "local_enable=YES" >> /etc/vsftpd.conf && \
    echo "dirmessage_enable=YES" >> /etc/vsftpd.conf && \
    echo "use_localtime=YES" >> /etc/vsftpd.conf && \
    echo "xferlog_enable=YES" >> /etc/vsftpd.conf && \
    echo "connect_from_port_20=YES" >> /etc/vsftpd.conf && \
    echo "xferlog_file=/var/log/vsftpd.log" >> /etc/vsftpd.conf && \
    echo "secure_chroot_dir=/var/run/vsftpd/empty" >> /etc/vsftpd.conf && \
    echo "pam_service_name=vsftpd" >> /etc/vsftpd.conf && \
    echo "anon_root=/var/ftp" >> /etc/vsftpd.conf && \
    echo "no_anon_password=YES" >> /etc/vsftpd.conf

# Création du dossier vide nécessaire pour le chroot
RUN mkdir -p /var/run/vsftpd/empty

# 4. Configuration Wazuh pour lire les logs FTP
RUN sed -i '/<\/ossec_config>/i \
  <localfile>\n\
    <location>/var/log/vsftpd.log</location>\n\
    <log_format>syslog</log_format>\n\
  </localfile>' /var/ossec/etc/ossec.conf

# --- AJOUT SCÉNARIO ---

# A. Création de l'utilisateur système 'ftpuser'
# On lui donne un mot de passe qu'on va cacher dans le FTP
RUN useradd -m -s /bin/bash ftpuser
RUN echo "ftpuser:ftproot123" | chpasswd

# B. L'Indice (Loot)
# On place le mot de passe dans le dossier anonyme pour que l'attaquant le trouve
RUN echo "Pour l'admin : le compte système est 'ftpuser' et le pass est 'ftproot123'. N'oublie pas de supprimer ce fichier !" > /var/ftp/pub/creds.txt

# C. Installation de SSH (Pour se connecter une fois le mdp trouvé)
RUN apt-get update && apt-get install -y openssh-server vim sudo rsyslog iptables && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd
# Activer les logs SSH
RUN sed -i 's/#SyslogFacility AUTH/SyslogFacility AUTH/' /etc/ssh/sshd_config && \
    sed -i 's/#LogLevel INFO/LogLevel INFO/' /etc/ssh/sshd_config

# Format traditionnel rsyslog
RUN echo '$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat' > /etc/rsyslog.d/traditional.conf

# D. LA FAILLE ROOT (Sudo Vim)
# On autorise ftpuser à lancer vim en tant que root sans mot de passe
RUN echo "ftpuser ALL=(root) NOPASSWD: /usr/bin/vim" >> /etc/sudoers

# E. LE FLAG FINAL (ROOT ONLY)
# On crée le fichier directement chez le root
RUN echo "FLAG{FTP_ROOT_VICTORY_SUCCES}" > /root/root_flag.txt

# On verrouille le fichier (Seul le propriétaire 'root' peut lire/écrire)
# 600 = rw------- (Lecture/Ecriture pour root, RIEN pour les autres)
RUN chmod 600 /root/root_flag.txt

# 5. Démarrage
# Fix rsyslog : format traditionnel pour Wazuh
COPY 50-default.conf /etc/rsyslog.d/50-default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
