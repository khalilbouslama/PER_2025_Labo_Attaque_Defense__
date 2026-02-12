#!/bin/bash
echo "--> Démarrage de rsyslog..."
rm -f /run/rsyslogd.pid /dev/log
/usr/sbin/rsyslogd
sleep 1

echo "--> Démarrage de Wazuh Agent..."
service wazuh-agent start

echo "--> Démarrage des services..."
service apache2 start
service ssh start
service cron start

echo "--> Conteneur prêt. Logs :"
tail -f /var/log/apache2/access.log
