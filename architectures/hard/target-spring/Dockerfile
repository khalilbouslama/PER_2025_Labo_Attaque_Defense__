FROM ubuntu:20.04

# Installation des dépendances (Java pour le réalisme + Python pour le serveur web)
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    netcat \
    curl \
    sudo \
    cron \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Création de l'utilisateur "john" (Le développeur débutant)
RUN useradd -m -s /bin/bash john
RUN echo "john:password123" | chpasswd

# Configuration de l'application "Spring" (Fake)
WORKDIR /app
COPY src/server.py /app/server.py
COPY src/entrypoint.sh /entrypoint.sh

# Permissions
RUN chown -R john:john /app
RUN chmod +x /entrypoint.sh

# --- FAILLES ---

# 1. Flag User
RUN echo "FLAG{SPRING_BOOT_RCE_USER}" > /home/john/user_flag.txt
RUN chown john:john /home/john/user_flag.txt
RUN chmod 600 /home/john/user_flag.txt

# 2. Flag Root
RUN echo "FLAG{JAVA_WILDCARD_INJECTION_ROOT}" > /root/root_flag.txt
RUN chmod 600 /root/root_flag.txt

# 3. Escalade de Privilèges : Cron Job vulnérable (Wildcard Injection)
# John a fait un script de backup en Java qui tourne en root
COPY src/backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh
RUN echo "* * * * * root /usr/local/bin/backup.sh" >> /etc/crontab

# Exposition du port classique de Spring Boot
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
