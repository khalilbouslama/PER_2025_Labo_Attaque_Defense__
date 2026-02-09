FROM ubuntu:20.04

# Éviter les questions interactives lors de l'install
ENV DEBIAN_FRONTEND=noninteractive

# 1. Installation des paquets (Samba, Python, Outils réseau)
RUN apt-get update && apt-get install -y \
    samba \
    python3 \
    python3-pip \
    libcap2-bin \
    openssh-server \
    netcat \
    iproute2 \
    curl \
    gnupg \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation de l'agent Wazuh
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add - && \
    echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && apt-get install -y wazuh-agent

# 3. Création de l'utilisateur légitime (que l'étudiant va voler)
# Mot de passe : "S3cur3P@ssw0rd!" (C'est ce qu'il devra trouver)
RUN useradd -m -s /bin/bash system_admin && \
    echo "system_admin:SuperSambaPassword!" | chpasswd

# 3. Configuration SSH (Pour qu'on puisse se connecter)
RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 4. Mise en place de la faille "Misconfiguration" (Fuite de données)
RUN mkdir -p /srv/samba/backups
# On crée un script python qui contient le mot de passe en clair
RUN echo "db_password = 'SuperSambaPassword!'" > /srv/samba/backups/config.py
RUN chmod 644 /srv/samba/backups/config.py

# 5. Mise en place de la faille "Capabilities" (Escalade Root)
# On donne à Python le droit de changer d'UID (devenir Root)
RUN setcap cap_setuid+ep /usr/bin/python3.8


# 8. Les Flags
RUN echo "FLAG{MEDIUM_SAMBA_USER_FOUND}" > /home/system_admin/user_flag.txt
RUN chown system_admin:system_admin /home/system_admin/user_flag.txt

RUN echo "FLAG{MEDIUM_SAMBA_PYTHON_CAPS}" > /root/root_flag.txt
RUN chmod 600 /root/root_flag.txt


# 6. Configuration Samba et Wazuh
COPY smb.conf /etc/samba/smb.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Ports Samba
EXPOSE 139 445 22 

ENTRYPOINT ["/entrypoint.sh"]
