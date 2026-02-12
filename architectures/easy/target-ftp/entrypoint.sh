#!/bin/bash
echo "--> Démarrage de rsyslog..."
rm -f /run/rsyslogd.pid /dev/log
/usr/sbin/rsyslogd
sleep 1
echo "--> Démarrage de Wazuh Agent..."
service wazuh-agent start
echo "--> Démarrage du serveur SSH..."
service ssh start
echo "--> Démarrage du serveur FTP..."
touch /var/log/vsftpd.log
/usr/sbin/vsftpd &
sleep 1
echo "--> Conteneur prêt. Logs :"
tail -f /var/log/vsftpd.log
