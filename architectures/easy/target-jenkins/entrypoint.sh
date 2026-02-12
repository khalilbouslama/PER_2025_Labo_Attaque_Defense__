#!/bin/bash
echo "--> Démarrage de rsyslog..."
rm -f /run/rsyslogd.pid /dev/log
/usr/sbin/rsyslogd
sleep 1

echo "--> Démarrage de Wazuh Agent..."
service wazuh-agent start

echo "--> Lancement de Jenkins..."
su jenkins -c "/usr/bin/tini -- /usr/local/bin/jenkins.sh"
