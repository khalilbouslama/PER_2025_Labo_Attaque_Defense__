#!/bin/bash

echo "[INFO] Démarrage du serveur web Apache..."
# On lance Apache en arrière-plan
docker-php-entrypoint apache2-foreground &

# On attend quelques secondes que Apache soit chaud
sleep 2

echo "[INFO] Démarrage du Bot Hakan..."
# On lance le script du bot EN TANT QUE L'UTILISATEUR HAKAN (pas root)
# C'est crucial : l'attaquant aura un shell "hakan" et devra faire une escalade de privilèges.
su hakan -c "/bin/bash /bot.sh"
