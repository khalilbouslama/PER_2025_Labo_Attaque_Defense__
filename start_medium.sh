#!/bin/bash

# ============================================================
# SCRIPT DE LANCEMENT - ARCHITECTURE MEDIUM
# ============================================================

echo "🧹 [0/3] Arrêt des conflits potentiels (Easy)..."
cd /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/medium
sudo docker-compose down 2>/dev/null

echo "🔵 [1/3] Démarrage du Commissariat (Wazuh Blue Team)..."
cd /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/medium
sudo docker-compose up -d
echo "   ⏳ Attente de 30 secondes pour Wazuh..."
sleep 30

echo "🟠 [2/3] Démarrage du Labo MEDIUM..."
cd /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/easy
sudo docker-compose up -d --build

echo "🔄 [3/3] Réveil des agents..."
# On force le redémarrage pour l'enregistrement
sudo docker exec target_web_medium service wazuh-agent restart
sudo docker exec target_ftp_medium service wazuh-agent restart
sudo docker exec target_samba_medium service wazuh-agent restart
sudo docker exec target_jenkins_medium service wazuh-agent restart

echo "============================================================"
echo "✅ LABO MEDIUM PRÊT !"
echo "============================================================"
echo "📊 Dashboard : https://127.0.0.1"
echo "🗡️  ATTAQUANT : ssh root@127.0.0.1 -p 2222 (Mdp: root)"
echo "🎯 CIBLE     : http://172.21.0.40 (Depuis la Kali)"
echo "============================================================"
