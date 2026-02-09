#!/bin/bash

# Configuration dynamique de l'IP Wazuh
if [ ! -z "$WAZUH_MANAGER_IP" ]; then
    sed -i "s/MANAGER_IP/$WAZUH_MANAGER_IP/g" /var/ossec/etc/ossec.conf
    sed -i "s/<address>wazuh.manager<\/address>/<address>$WAZUH_MANAGER_IP<\/address>/g" /var/ossec/etc/ossec.conf
fi

# Démarrage de l'agent Wazuh
service wazuh-agent start

# Démarrage de SSH (pour que l'étudiant se connecte une fois la clé uploadée)
service ssh start

# Démarrage de Samba
service smbd start

# On garde le conteneur en vie (Samba passe en arrière-plan par défaut)
tail -f /var/log/samba/log.smbd
