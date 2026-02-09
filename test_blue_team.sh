#!/bin/bash
echo "============================================"
echo "  TEST COMPLET - Blue Team Easy (23 règles)"
echo "============================================"

# ========== PRÉREQUIS : Démarrer rsyslog + fixer permissions ==========
echo ""
echo "[0/6] Préparation des conteneurs..."
for container in target_samba_easy target_jenkins_easy target_apache_easy; do
  sudo docker exec $container bash -c '
    chown syslog:adm /var/log/auth.log 2>/dev/null
    chmod 640 /var/log/auth.log 2>/dev/null
    killall rsyslogd 2>/dev/null
    rm -f /run/rsyslogd.pid
    sleep 1
    rsyslogd 2>/dev/null
    sed -i "s/#SyslogFacility AUTH/SyslogFacility AUTH/" /etc/ssh/sshd_config 2>/dev/null
    sed -i "s/#LogLevel INFO/LogLevel INFO/" /etc/ssh/sshd_config 2>/dev/null
  ' 2>/dev/null
done
echo "✅ Conteneurs préparés"
sleep 5

# ========== 1. FTP (100011, 100020, 100021) ==========
echo ""
echo "[1/6] Test FTP (100011, 100020, 100021)..."
sudo docker exec kali_easy bash -c '
ftp -n target_ftp_easy << FTPEOF
user anonymous anon@test.com
get /pub/flag.txt
bye
FTPEOF
' 2>/dev/null
echo "✅ FTP testé"

# ========== 2. SAMBA (100030, 100032, 100033, 100034) ==========
echo ""
echo "[2/6] Test Samba (100030, 100032, 100033, 100034)..."
sudo docker exec kali_easy bash -c '
for i in $(seq 1 6); do
  smbclient //target_samba_easy/public -U sambauser%princess1 -c "ls; get note_service.txt" 2>/dev/null
done
' 2>/dev/null
echo "✅ Samba testé"

# ========== 3. SSH (100036, 100037, 100038, 100039) ==========
echo ""
echo "[3/6] Test SSH (100036, 100037, 100038, 100039)..."
sudo docker exec kali_easy bash -c '
# Brute force (100038 + 100037)
for i in $(seq 1 10); do
  sshpass -p "wrongpass" ssh -o StrictHostKeyChecking=no fakeuser@target_samba_easy 2>/dev/null
done
# Connexion réussie (100036 + 100039)
sshpass -p "princess1" ssh -o StrictHostKeyChecking=no sambauser@target_samba_easy whoami
' 2>/dev/null
echo "✅ SSH testé"

# ========== 4. ESCALADE SAMBA (100040, 100041) ==========
echo ""
echo "[4/6] Test Escalade Samba (100040, 100041)..."
sudo docker exec target_samba_easy bash -c '
logger -p auth.info "find / -perm -4000 -type f"
logger -p auth.info "find . -exec /bin/sh -p"
'
echo "✅ Escalade Samba testé"

# ========== 5. JENKINS (100050, 100051, 100052, 100053) ==========
echo ""
echo "[5/6] Test Jenkins (100050, 100051, 100052, 100053)..."
sudo docker exec target_jenkins_easy bash -c '
logger -p auth.info "script /dev/null -c bash"
logger -p auth.info "sudo vim -c :!/bin/bash"
echo "Feb  9 12:00:00 target-jenkins sudo: jenkins : TTY=pts/0 ; PWD=/home/jenkins ; USER=root ; COMMAND=/usr/bin/vim -c :!/bin/bash" >> /var/log/auth.log
logger -p auth.info "pam_unix(sudo:session): session opened for user root(uid=0) by (uid=1000)"
'
echo "✅ Jenkins testé"

# ========== 6. APACHE (100060, 100062, 100063, 100064, 100066, 100067) ==========
echo ""
echo "[6/6] Test Apache (100060, 100062, 100063, 100064, 100066, 100067)..."
# 100060 + 100066 + 100067 : accès massifs à backup_key.pem
sudo docker exec kali_easy bash -c '
for i in $(seq 1 15); do
  curl -s http://target_apache_easy/backup_key.pem > /dev/null
done
' 2>/dev/null
# 100062 : SSH webuser login
sudo docker exec target_apache_easy bash -c '
echo "Feb  9 12:00:00 target-apache sshd[999]: Accepted publickey for webuser from 172.25.0.3 port 44000 ssh2" >> /var/log/auth.log
'
# 100064 : SUID bash
sudo docker exec target_apache_easy bash -c '
echo "2026-02-09T12:00:00+00:00 target-apache root: /usr/bin/bash -p" >> /var/log/auth.log
'
# 100063 : syscheck modification
sudo docker exec target_apache_easy bash -c '
chmod u+s /usr/bin/bash
touch /usr/bin/bash
'
sudo docker exec single-node-wazuh.manager-1 /var/ossec/bin/agent_control -r -a 2>/dev/null
echo "✅ Apache testé"

# ========== RÉSULTATS ==========
echo ""
echo "⏳ Attente 60 secondes (syscheck scan)..."
sleep 60

echo ""
echo "============================================"
echo "  RÉSULTATS - Alertes déclenchées"
echo "============================================"
sudo docker exec single-node-wazuh.manager-1 bash -c '
echo ""
echo "=== COMPTEUR PAR RÈGLE ==="
grep "Rule: 100" /var/ossec/logs/alerts/alerts.log | sed "s/.*Rule: //" | sort | uniq -c | sort -rn
echo ""
echo "=== DÉTAIL FTP ==="
grep -E "Rule: 10001[1]|Rule: 10002[01]" /var/ossec/logs/alerts/alerts.log | tail -5
echo ""
echo "=== DÉTAIL SAMBA ==="
grep -E "Rule: 10003[0234]" /var/ossec/logs/alerts/alerts.log | tail -5
echo ""
echo "=== DÉTAIL SSH ==="
grep -E "Rule: 10003[6789]" /var/ossec/logs/alerts/alerts.log | tail -5
echo ""
echo "=== DÉTAIL ESCALADE ==="
grep -E "Rule: 10004[01]" /var/ossec/logs/alerts/alerts.log | tail -5
echo ""
echo "=== DÉTAIL JENKINS ==="
grep -E "Rule: 10005[0-3]" /var/ossec/logs/alerts/alerts.log | tail -5
echo ""
echo "=== DÉTAIL APACHE ==="
grep -E "Rule: 10006[0-7]" /var/ossec/logs/alerts/alerts.log | tail -5
'

echo ""
echo "============================================"
echo "  ✅ TEST TERMINÉ"
echo "  Vérifiez aussi le dashboard Wazuh :"
echo "  https://127.0.0.1 (admin / SecretPassword)"
echo "============================================"
