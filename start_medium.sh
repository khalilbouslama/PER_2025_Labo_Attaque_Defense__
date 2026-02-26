#!/bin/bash
# ============================================================
# SCRIPT DE LANCEMENT - ARCHITECTURE MEDIUM
# ============================================================
CONTAINERS="target_ftp_medium target_samba_medium target_jenkins_medium target_web_medium"

echo "🔌 [0/5] Arret de l'architecture Easy si active..."
sudo docker-compose -f /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/easy/docker-compose.yml down 2>/dev/null || true
sudo docker network disconnect easy_net_easy single-node-wazuh.manager-1 2>/dev/null || true
sudo docker network disconnect easy_net_public_easy single-node-wazuh.manager-1 2>/dev/null || true
sudo docker network disconnect easy_net_private_easy single-node-wazuh.manager-1 2>/dev/null || true

echo "🧹 [1/5] Démarrage du Labo MEDIUM..."
cd /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/medium
sudo docker-compose up -d --build --force-recreate
echo "   ⏳ Attente de 30 secondes..."
sleep 30

echo "🔧 [2/5] Récupération IP manager et configuration agents..."
sudo docker network connect medium_net_private_medium single-node-wazuh.manager-1 2>/dev/null || true
sleep 5
MANAGER_IP=$(sudo docker inspect single-node-wazuh.manager-1 | python3 -c "import sys,json; nets=json.load(sys.stdin)[0]['NetworkSettings']['Networks']; print(nets.get('medium_net_private_medium',{}).get('IPAddress',''))")
echo "Manager IP medium : $MANAGER_IP"

for container in $CONTAINERS; do
  sudo docker exec -u root $container bash -c \
    "sed -i 's|<address>.*</address>|<address>${MANAGER_IP}</address>|' /var/ossec/etc/ossec.conf"
done

echo "🔑 [3/5] Injection des clés d'enrôlement..."
declare -A medium_agents=(
  ["043"]="target_ftp_medium"
  ["042"]="target_samba_medium"
  ["046"]="target_jenkins_medium"
  ["047"]="target_web_medium"
)
for agent_id in 043 042 046 047; do
  container=${medium_agents[$agent_id]}
  key=$(sudo docker exec single-node-wazuh.manager-1 grep "^${agent_id} " /var/ossec/etc/client.keys)
  if [ -n "$key" ]; then
    sudo docker exec -u root $container bash -c \
      "echo '${key}' > /var/ossec/etc/client.keys && \
       chmod 640 /var/ossec/etc/client.keys && \
       chown root:wazuh /var/ossec/etc/client.keys"
    echo "✓ Clé injectée : $container"
  else
    echo "✗ Clé non trouvée pour $agent_id"
  fi
done

echo "🔄 [4/5] Réveil des agents..."
for container in $CONTAINERS; do
  sudo docker exec -u root $container /var/ossec/bin/wazuh-control restart
done
sleep 20

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
echo "🎯 CIBLE WEB : http://172.25.0.40 (Depuis la Kali)"
echo "============================================================"
echo ""
echo "Vérification des agents :"
sudo docker exec single-node-wazuh.manager-1 \
  /var/ossec/bin/agent_control -l | grep medium
