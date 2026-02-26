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
# Connecter le manager aux réseaux Easy
sudo docker network connect easy_net_public_easy single-node-wazuh.manager-1 2>/dev/null || true
sudo docker network connect easy_net_private_easy single-node-wazuh.manager-1 2>/dev/null || true

sleep 5

# Récupérer les IPs du manager sur chaque réseau
IP_PUBLIC=$(sudo docker inspect single-node-wazuh.manager-1 | python3 -c "import sys,json; nets=json.load(sys.stdin)[0]['NetworkSettings']['Networks']; print(nets.get('easy_net_public_easy',{}).get('IPAddress',''))")
IP_PRIVATE=$(sudo docker inspect single-node-wazuh.manager-1 | python3 -c "import sys,json; nets=json.load(sys.stdin)[0]['NetworkSettings']['Networks']; print(nets.get('easy_net_private_easy',{}).get('IPAddress',''))")

echo "Manager IP public easy : $IP_PUBLIC"
echo "Manager IP private easy : $IP_PRIVATE"

# Configurer chaque agent avec la bonne IP
sudo docker exec target_ftp_easy bash -c "sed -i 's|<address>.*</address>|<address>${IP_PUBLIC}</address>|' /var/ossec/etc/ossec.conf"
sudo docker exec target_samba_easy bash -c "sed -i 's|<address>.*</address>|<address>${IP_PUBLIC}</address>|' /var/ossec/etc/ossec.conf"
sudo docker exec target_jenkins_easy bash -c "sed -i 's|<address>.*</address>|<address>${IP_PUBLIC}</address>|' /var/ossec/etc/ossec.conf"
sudo docker exec target_apache_easy bash -c "sed -i 's|<address>.*</address>|<address>${IP_PRIVATE}</address>|' /var/ossec/etc/ossec.conf"

# Injection des clés Easy
declare -A easy_agents=(
  ["057"]="target_ftp_easy"
  ["058"]="target_samba_easy"
  ["059"]="target_apache_easy"
  ["060"]="target_jenkins_easy"
)
for agent_id in 057 058 059 060; do
  container=${easy_agents[$agent_id]}
  key=$(sudo docker exec single-node-wazuh.manager-1 grep "^${agent_id} " /var/ossec/etc/client.keys)
  if [ -n "$key" ]; then
    sudo docker exec $container bash -c \
      "echo '${key}' > /var/ossec/etc/client.keys && \
       chmod 640 /var/ossec/etc/client.keys && \
       chown root:wazuh /var/ossec/etc/client.keys"
    echo "✓ Clé injectée : $container"
  else
    echo "✗ Clé non trouvée pour $agent_id"
  fi
done
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
