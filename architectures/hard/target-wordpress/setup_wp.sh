#!/bin/bash

# 1. ATTENTE DE LA BASE DE DONNÉES
echo "[INFO] Waiting for Database connection..."
until nc -z -v -w30 target-db 3306
do
  echo "Waiting for database..."
  sleep 5
done
echo "[INFO] Database is UP!"

# 2. PRÉPARATION DES FICHIERS (CORRECTIF 403)
if [ ! -f /var/www/html/index.php ]; then
    echo "[INFO] Copying WordPress source files..."
    cp -r /usr/src/wordpress/* /var/www/html/
    chown -R www-data:www-data /var/www/html
fi

# 3. INSTALLATION AUTOMATISÉE
cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "[INFO] Starting WordPress auto-installation..."

    # A. Création du fichier de config
    wp config create \
        --dbname="wordpress" \
        --dbuser="wp_user" \
        --dbpass="wp_password" \
        --dbhost="target-db" \
        --allow-root --force

    # B. Installation de la BDD et de l'Admin
    wp core install \
        --url="http://172.23.0.20" \
        --title="TechCorp Blog" \
        --admin_user="admin" \
        --admin_password="Jenk!nsSuperSecret!" \
        --admin_email="admin@techcorp.local" \
        --skip-email \
        --allow-root

    # C. Permissions finales
    chown -R www-data:www-data /var/www/html
    
    echo "[INFO] WordPress Successfully Installed."
else
    echo "[INFO] WordPress is already installed."
fi

# 4. LANCEMENT DES SERVICES ADDITIONNELS (CRITIQUE)

# A. Démarrage de SSH (POUR LE PIVOT) <--- AJOUT ICI
echo "[INFO] Starting SSH Server..."
service ssh start

# B. Démarrage du CRON (Pour la faille Python)
# On s'assure que les lignes ne sont pas dupliquées à chaque redémarrage
if ! grep -q "system_monitor.py" /etc/crontab; then
    echo "PYTHONPATH=/var/www/html/wp-content/uploads" >> /etc/crontab
    echo "* * * * * root /usr/bin/python3 /usr/local/bin/system_monitor.py" >> /etc/crontab
fi
echo "[INFO] Starting Cron..."
service cron start

# 5. LANCEMENT D'APACHE (Processus Principal)
echo "[INFO] Starting Apache Server..."
exec docker-php-entrypoint apache2-foreground
