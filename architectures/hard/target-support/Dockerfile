FROM php:7.4-apache

# 1. Installation des dépendances (netcat pour le reverse shell, sudo pour l'escalade)
RUN apt-get update && apt-get install -y \
    netcat \
    iproute2 \
    sudo \
    cron \
    && rm -rf /var/lib/apt/lists/*

# 2. Création de l'utilisateur "hakan" (Le bot de support)
RUN useradd -m -s /bin/bash hakan
# On lui met un mot de passe (utile si l'étudiant veut tester su)
RUN echo "hakan:password123" | chpasswd

# 3. CRÉATION DE LA FAILLE PRIVILEGE ESCALATION (ROOT)
# Faille "GTFOBins" : on autorise hakan à lancer 'find' en tant que root sans mot de passe.
# L'étudiant devra faire : sudo find . -exec /bin/sh \; -quit
RUN echo "hakan ALL=(root) NOPASSWD: /usr/bin/find" >> /etc/sudoers

# 4. Le Flag Root
RUN echo "FLAG{HARD_SUPPORT_PHISHING_ROOT}" > /root/root_flag.txt
RUN chmod 600 /root/root_flag.txt

# 5. L'indice pour la machine suivante (Jenkins)
# Caché dans le dossier de hakan. L'étudiant le trouvera une fois connecté.
RUN echo "JENKINS_INTERNAL_IP: 172.23.0.20\nUSER: admin\nPASS: Jenk!nsSuperSecret!" > /home/hakan/internal_creds.txt
RUN chown hakan:hakan /home/hakan/internal_creds.txt
RUN chmod 600 /home/hakan/internal_creds.txt

# 6. Configuration Web
# On copie les sources
COPY src/ /var/www/html/
# On crée le dossier d'upload avec des droits larges (777)
# www-data doit pouvoir écrire (upload PHP) et hakan doit pouvoir lire/exécuter (Bot)
RUN mkdir -p /var/www/html/uploads && \
    chmod 777 /var/www/html/uploads && \
    chown www-data:www-data /var/www/html/uploads

# 7. Installation des scripts
COPY bot.sh /bot.sh
COPY start.sh /start.sh

# Permissions
RUN chmod +x /bot.sh /start.sh
# Le bot appartient à hakan (important pour que le shell obtenu soit hakan, pas root direct)
RUN chown hakan:hakan /bot.sh

EXPOSE 80

ENTRYPOINT ["/start.sh"]
