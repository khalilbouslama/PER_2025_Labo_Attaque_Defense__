#!/bin/bash
echo "--> Démarrage de rsyslog..."
rm -f /run/rsyslogd.pid /dev/log
/usr/sbin/rsyslogd
sleep 1

echo "--> Démarrage de Wazuh Agent..."
echo "--> Ouverture des ports Wazuh (1514/1515)..."
iptables -C INPUT  -p tcp --dport 1514 -j ACCEPT 2>/dev/null || iptables -I INPUT  -p tcp --dport 1514 -j ACCEPT
iptables -C INPUT  -p tcp --dport 1515 -j ACCEPT 2>/dev/null || iptables -I INPUT  -p tcp --dport 1515 -j ACCEPT
iptables -C OUTPUT -p tcp --dport 1514 -j ACCEPT 2>/dev/null || iptables -I OUTPUT -p tcp --dport 1514 -j ACCEPT
iptables -C OUTPUT -p tcp --dport 1515 -j ACCEPT 2>/dev/null || iptables -I OUTPUT -p tcp --dport 1515 -j ACCEPT
service wazuh-agent start

echo "--> Démarrage des services..."
service apache2 start
service ssh start
service cron start

echo "--> Conteneur prêt. Logs :"
tail -f /var/log/apache2/access.log
