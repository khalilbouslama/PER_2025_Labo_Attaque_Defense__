FROM debian:bullseye-slim

# 1. Installation des paquets (AJOUT DE openssh-server)
RUN apt-get update && apt-get install -y \
    vsftpd \
    openssh-server \
    cron \
    netcat-traditional \
    sudo \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# 1.5. Installation de l'agent Wazuh
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add - && \
    echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && apt-get install -y wazuh-agent && \
    rm -rf /var/lib/apt/lists/*
# 2. CRÉATION DE LA CIBLE (Utilisateur 'admin')
# Mot de passe : 123456
RUN useradd -m -d /home/admin -s /bin/bash admin && \
    echo "admin:abc123" | chpasswd


# 3. Configuration SSH (Pour qu'on puisse se connecter)
RUN mkdir /var/run/sshd
# On autorise le login par mot de passe (nécessaire si on n'a pas encore mis de clé)
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 4. Configuration FTP
RUN cp /etc/vsftpd.conf /etc/vsftpd.conf.orig && \
    sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf && \
    sed -i 's/#local_umask=022/local_umask=022/' /etc/vsftpd.conf && \
    echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf

# Fix dossier chroot
RUN mkdir -p /var/lib/vsftpd/empty
RUN echo "secure_chroot_dir=/var/lib/vsftpd/empty" >> /etc/vsftpd.conf

# 5. CONFIGURATION FAILLE CRON
RUN mkdir -p /opt/scripts
RUN echo '#!/bin/bash\n# Maintenance\n# Rien a signaler' > /opt/scripts/maintenance.sh
RUN chmod +x /opt/scripts/maintenance.sh
RUN chown admin:admin /opt/scripts/maintenance.sh
RUN echo "* * * * * root /opt/scripts/maintenance.sh" >> /etc/crontab

# 6. Flags
RUN echo "FLAG{MEDIUM_FTP_USER_ACCESS}" > /home/admin/user_flag.txt
RUN chown admin:admin /home/admin/user_flag.txt
RUN echo "FLAG{MEDIUM_FTP_ROOT_CRON}" > /root/root_flag.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# On expose le 21 (FTP) ET le 22 (SSH)
EXPOSE 21 22
ENTRYPOINT ["/entrypoint.sh"]
