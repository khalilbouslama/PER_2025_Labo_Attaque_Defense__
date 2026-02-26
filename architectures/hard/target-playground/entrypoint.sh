#!/bin/bash

# ⚠️ Faille simulée : On rend le socket docker accessible à tout le monde
# Dans la réalité, cela arrive quand un admin ajoute l'utilisateur au groupe 'docker'
# ou fait un chmod imprudent.
if [ -S /var/run/docker.sock ]; then
    chmod 666 /var/run/docker.sock
fi

# On lance l'application en tant que l'utilisateur "developer" (pas root !)
su developer -c "python3 app.py"
