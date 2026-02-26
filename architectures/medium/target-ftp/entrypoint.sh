#!/bin/bash

# Configuration dynamique de l'IP Wazuh
if [ ! -z "$WAZUH_MANAGER_IP" ]; then
    sed -i "s/MANAGER_IP/$WAZUH_MANAGER_IP/g" /var/ossec/etc/ossec.conf
    sed -i "s/<address>wazuh.manager<\/address>/<address>$WAZUH_MANAGER_IP<\/address>/g" /var/ossec/etc/ossec.conf
fi

# Démarrage de l'agent Wazuh
sed -i "/</ossec_config>/i \
  <localfile>\
    <log_format>syslog</log_format>\
    <location>/var/log/commands.log</location>\
  </localfile>" /var/ossec/etc/ossec.conf
service wazuh-agent start

# Démarrage de SSH (pour que l'étudiant se connecte une fois la clé uploadée)
service ssh start

# Démarrage de Cron (pour exécuter le script malveillant)
service cron start

# Démarrage du serveur FTP (en premier plan pour garder le conteneur actif)
# On utilise /usr/sbin/vsftpd directement
/usr/sbin/vsftpd /etc/vsftpd.conf
