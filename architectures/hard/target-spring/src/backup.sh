#!/bin/bash
# Script de sauvegarde automatique créé par John
# Il sauvegarde le dossier de l'application
cd /app
tar -czf /tmp/backup.tar.gz *
