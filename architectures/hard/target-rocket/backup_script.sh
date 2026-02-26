#!/bin/bash
cd /var/www/html

# ⚠️ FAILLE ROOT : Wildcard Injection
# Si un attaquant crée des fichiers nommés "--checkpoint=1" et "--checkpoint-action=exec=...",
# tar va les interpréter comme des options et exécuter une commande !
tar -czf /tmp/backup.tar.gz *
