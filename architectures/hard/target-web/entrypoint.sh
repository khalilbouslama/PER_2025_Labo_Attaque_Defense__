#!/bin/bash

# Démarrer SSH (pour le futur pivot)
service ssh start

# Démarrer Apache en premier plan (pour garder le conteneur actif)
docker-php-entrypoint apache2-foreground
