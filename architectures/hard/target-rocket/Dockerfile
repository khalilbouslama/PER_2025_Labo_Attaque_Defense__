FROM php:7.4-apache

# 1. Installation de Cron et Netcat (pour le Reverse Shell)
RUN apt-get update && apt-get install -y \
    cron \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuration du site
WORKDIR /var/www/html
COPY index.php .
COPY intro.txt .
COPY specs.txt .

# 3. Configuration des Logs pour le "Log Poisoning"
# Par défaut, Docker envoie les logs vers la sortie standard (stdout).
# On doit forcer Apache à écrire dans un vrai fichier.
RUN echo "ErrorLog /var/log/apache2/error.log" >> /etc/apache2/apache2.conf
RUN echo "CustomLog /var/log/apache2/access.log combined" >> /etc/apache2/apache2.conf

# ⚠️ FAILLE CRITIQUE 1 : Les logs doivent être lisibles par l'utilisateur www-data
# Cela permet à l'attaquant d'inclure le fichier de log via PHP.
RUN rm -f /var/log/apache2/access.log /var/log/apache2/error.log && \
    touch /var/log/apache2/access.log /var/log/apache2/error.log && \
    chown www-data:www-data /var/log/apache2/access.log /var/log/apache2/error.log && \
    chmod 777 /var/log/apache2/access.log /var/log/apache2/error.log

# On force Apache à utiliser ces fichiers
RUN echo "ErrorLog /var/log/apache2/error.log" >> /etc/apache2/apache2.conf
RUN echo "CustomLog /var/log/apache2/access.log combined" >> /etc/apache2/apache2.conf
# 4. Configuration de la Faille ROOT (Tar Wildcard)
# On crée un script de backup qui tourne en root
COPY backup_script.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# On crée la tâche Cron (toutes les minutes)
RUN echo "* * * * * root /usr/local/bin/backup.sh" >> /etc/crontab

# 5. Les Flags
# User Flag (accessible par www-data)
RUN echo "FLAG{HARD_LFI_LOG_POISONING_SUCCESS}" > /var/www/user_flag.txt
# Root Flag
RUN echo "FLAG{HARD_TAR_WILDCARD_INJECTION_PWNED}" > /root/root_flag.txt

# 6. Démarrage
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
