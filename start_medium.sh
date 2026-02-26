#!/bin/bash
# ============================================================
# SCRIPT DE LANCEMENT - ARCHITECTURE MEDIUM
# ============================================================

MANAGER_IP="172.23.0.2"
CONTAINERS="target_ftp_medium target_samba_medium target_jenkins_medium target_web_medium"

echo "🧹 [1/4] Démarrage du Labo MEDIUM..."
echo "🔌 [0/5] Déconnexion du manager des réseaux Easy..."
sudo docker network disconnect easy_net_easy single-node-wazuh.manager-1 2>/dev/null || true
sudo docker-compose -f /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/easy/docker-compose.yml down 2>/dev/null || true
cd /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/medium
sudo docker-compose up -d --build --force-recreate

echo "   ⏳ Attente de 30 secondes..."
sleep 30

echo "🔧 [2/4] Correction IP manager sur les agents..."
for container in $CONTAINERS; do
  sudo docker exec -u root $container bash -c \
    "sed -i 's|<address>.*</address>|<address>${MANAGER_IP}</address>|' /var/ossec/etc/ossec.conf"
done

echo "🔑 [3/4] Injection des clés d'enrôlement..."
python3 /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/fix_keys_medium.py

echo "🔄 [4/4] Réveil des agents..."
for container in $CONTAINERS; do
  sudo docker exec -u root $container /var/ossec/bin/wazuh-control restart
done

sleep 10

echo "📋 [5/5] Déploiement des règles de détection Medium..."
sudo docker cp /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/wazuh-config/local_rules.xml \
  single-node-wazuh.manager-1:/var/ossec/etc/rules/local_rules.xml
sudo docker exec single-node-wazuh.manager-1 \
  /var/ossec/bin/wazuh-control restart 2>/dev/null | tail -2

sleep 20

echo "============================================================"
echo "✅ LABO MEDIUM PRÊT !"
echo "============================================================"
echo "📊 Dashboard : https://127.0.0.1"
echo "🗡️  ATTAQUANT : ssh root@127.0.0.1 -p 2222 (Mdp: root)"
echo "🎯 CIBLE WEB : http://172.23.0.10 (Depuis la Kali)"
echo "============================================================"
echo ""
echo "Vérification des agents :"
sudo docker exec single-node-wazuh.manager-1 \
  /var/ossec/bin/agent_control -l | grep medium
