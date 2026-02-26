FROM wordpress:php7.4-apache

# 1. Installation des outils (Python pour la privesc, Netcat pour le shell, Cron)
RUN apt-get update && apt-get install -y \
    python3 \
    cron \
    netcat \
    sudo \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation de WP-CLI (Outil pour configurer WP automatiquement)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# 3. PRIVILEGE ESCALATION : Python Library Hijacking
# Le scénario : Un script root execute python et importe un module "status_check".

# a) Création du script root (simule un outil de monitoring système)
RUN echo "import os; import status_check; print('System Check OK')" > /usr/local/bin/system_monitor.py

# b) Création de la fausse librairie "status_check.py" dans le dossier Uploads
# IMPORTANT : On crée le dossier manuellement car il n'existe pas au build.
# On met des droits 777 sur le dossier ET le fichier pour faciliter l'écriture par www-data.
RUN mkdir -p /var/www/html/wp-content/uploads && \
    echo "def check(): print('Running diagnostics...')" > /var/www/html/wp-content/uploads/status_check.py && \
    chmod 777 /var/www/html/wp-content/uploads && \
    chmod 777 /var/www/html/wp-content/uploads/status_check.py

RUN mkdir /var/run/sshd
# 1. On définit le mot de passe root (Note-le bien !)
RUN echo 'root:rootpassword' | chpasswd
# 2. On autorise la connexion root via SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# c) On configure la variable PYTHONPATH
# C'est LA faille : Python va chercher les modules ici AVANT les modules systèmes.
ENV PYTHONPATH="/var/www/html/wp-content/uploads"

# d) Tâche Cron Root
# Execute le script toutes les minutes
RUN echo "* * * * * root /usr/bin/python3 /usr/local/bin/system_monitor.py" >> /etc/crontab

# 4. Le Flag Root
RUN echo "FLAG{HARD_WORDPRESS_PYTHON_HIJACK}" > /root/root_flag.txt
RUN chmod 600 /root/root_flag.txt

# 5. Script d'initialisation
COPY setup_wp.sh /setup_wp.sh
RUN chmod +x /setup_wp.sh

ENTRYPOINT ["/setup_wp.sh"]
