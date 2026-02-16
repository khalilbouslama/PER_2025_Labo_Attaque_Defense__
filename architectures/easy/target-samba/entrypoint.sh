#!/bin/bash

# 1. Démarrer rsyslog EN PREMIER (pour que auth.log fonctionne)
echo "--> Démarrage de rsyslog..."
rm -f /run/rsyslogd.pid /dev/log
/usr/sbin/rsyslogd
sleep 1

# 2. Démarrer l'agent Wazuh
echo "--> Démarrage de Wazuh Agent..."
echo "--> Ouverture des ports Wazuh (1514/1515)..."
iptables -C INPUT  -p tcp --dport 1514 -j ACCEPT 2>/dev/null || iptables -I INPUT  -p tcp --dport 1514 -j ACCEPT
iptables -C INPUT  -p tcp --dport 1515 -j ACCEPT 2>/dev/null || iptables -I INPUT  -p tcp --dport 1515 -j ACCEPT
iptables -C OUTPUT -p tcp --dport 1514 -j ACCEPT 2>/dev/null || iptables -I OUTPUT -p tcp --dport 1514 -j ACCEPT
iptables -C OUTPUT -p tcp --dport 1515 -j ACCEPT 2>/dev/null || iptables -I OUTPUT -p tcp --dport 1515 -j ACCEPT
service wazuh-agent start

# 3. Démarrer Samba
echo "--> Démarrage de Samba..."
service nmbd start
service smbd start

# 4. Démarrer SSH
echo "--> Démarrage de SSH..."
service ssh start

# 5. Boucle infinie
echo "--> Conteneur prêt. Surveillance des logs..."
tail -f /var/ossec/logs/ossec.log
