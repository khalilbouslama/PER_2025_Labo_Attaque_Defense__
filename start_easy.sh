#!/bin/bash
# ============================================================
# SCRIPT DE LANCEMENT - ARCHITECTURE EASY
# ============================================================

echo "============================================================"
echo "   ARCHITECTURE EASY - MODE DE DEMONSTRATION"
echo "============================================================"
echo ""
echo "Choisissez le mode :"
echo "  [1] DETECTION SEULE  - Remontee de logs uniquement (pas de blocage)"
echo "  [2] DETECTION + BLOCAGE - Active Response + firewall-drop active"
echo ""
read -p "Votre choix [1/2] : " MODE

if [ "$MODE" = "1" ]; then
    echo "Mode DETECTION SEULE selectionne"
    AR_MODE="detection"
elif [ "$MODE" = "2" ]; then
    echo "Mode DETECTION + BLOCAGE selectionne"
    AR_MODE="blocking"
else
    echo "Choix invalide. Mode DETECTION SEULE par defaut."
    AR_MODE="detection"
fi

echo "[1/4] Demarrage du Wazuh Manager..."
cd ~/Desktop/PER_2025_Labo_Attaque_Defense__/wazuh-docker/single-node
sudo docker-compose up -d
sleep 30

echo "[2/4] Demarrage de l architecture Easy..."
cd ~/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/easy
sudo docker-compose up -d

echo "[3/4] Connexion du Manager au reseau Easy..."
sudo docker network connect easy_net_easy single-node-wazuh.manager-1 2>/dev/null || true

echo "[4/4] Reveil des agents..."
sleep 10
sudo docker exec target_ftp_easy service wazuh-agent restart 2>/dev/null
sudo docker exec target_apache_easy service wazuh-agent restart 2>/dev/null
sudo docker exec target_samba_easy service wazuh-agent restart 2>/dev/null
sudo docker exec target_jenkins_easy service wazuh-agent restart 2>/dev/null
sleep 30

echo "Application du mode choisi..."
if [ "$AR_MODE" = "detection" ]; then
    sudo docker exec single-node-wazuh.manager-1 bash -c "cp /var/ossec/etc/ossec.conf.without_ar /var/ossec/etc/ossec.conf && /var/ossec/bin/wazuh-control restart"
    echo "   --> Active Response DESACTIVEE"
else
    sudo docker exec single-node-wazuh.manager-1 bash -c "cp /var/ossec/etc/ossec.conf.with_ar /var/ossec/etc/ossec.conf && /var/ossec/bin/wazuh-control restart"
    echo "   --> Active Response ACTIVEE"
fi

sleep 15

echo "Verification des agents :"
sudo docker exec single-node-wazuh.manager-1 /var/ossec/bin/agent_control -l | grep -E "easy|target"

echo ""
echo "============================================================"
if [ "$AR_MODE" = "detection" ]; then
    echo "LABO EASY PRET - MODE : DETECTION SEULE"
else
    echo "LABO EASY PRET - MODE : DETECTION + BLOCAGE"
fi
echo "============================================================"
echo "Dashboard Wazuh : https://127.0.0.1 (Login: admin / SecretPassword)"
echo "Manuel         : ssh root@127.0.0.1 -p 2222"
echo "============================================================"
