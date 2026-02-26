#!/bin/bash

# Démarrage de Cron (pour la faille Root)
service cron start

# Démarrage d'Apache en premier plan
docker-php-entrypoint apache2-foreground
