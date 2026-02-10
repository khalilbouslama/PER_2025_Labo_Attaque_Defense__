#!/bin/bash

# Configuration dynamique de l'IP Wazuh (via docker-compose)
if [ ! -z "$WAZUH_MANAGER_IP" ]; then
    sed -i "s/MANAGER_IP/$WAZUH_MANAGER_IP/g" /var/ossec/etc/ossec.conf
    sed -i "s/<address>wazuh.manager<\/address>/<address>$WAZUH_MANAGER_IP<\/address>/g" /var/ossec/etc/ossec.conf
fi

# Configurer Wazuh pour monitorer commands.log et auth.log AVANT de démarrer l'agent
sed -i '/<\/ossec_config>/i \
  <localfile>\
    <log_format>syslog</log_format>\
    <location>/var/log/commands.log</location>\
  </localfile>\
  <localfile>\
    <log_format>syslog</log_format>\
    <location>/var/log/auth.log</location>\
  </localfile>' /var/ossec/etc/ossec.conf

# Démarrage de l'agent Wazuh
service wazuh-agent start

# Démarrage du service SSH (POUR LE TUNNEL)
service ssh start

# Démarrage d'Apache en premier plan
apache2-foreground
