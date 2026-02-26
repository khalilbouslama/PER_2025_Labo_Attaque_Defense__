#!/bin/bash
service cron start
# On lance le serveur en tant que John (pas Root !)
su john -c "python3 /app/server.py"
