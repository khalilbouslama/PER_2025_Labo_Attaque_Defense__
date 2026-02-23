#!/bin/bash
# ============================================================
# SCRIPT DE LANCEMENT - ARCHITECTURE MEDIUM
# ============================================================

MANAGER_IP="172.23.0.2"
CONTAINERS="target_ftp_medium target_samba_medium target_jenkins_medium target_web_medium"

echo "🧹 [1/4] Démarrage du Labo MEDIUM..."
cd /home/kali/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/medium
sudo docker-compose up -d --build

echo "   ⏳ Attente de 30 secondes..."
sleep 30

echo "🔧 [2/4] Correction IP manager sur les agents..."
for container in $CONTAINERS; do
  sudo docker exec $container bash -c \
    "sed -i 's|<address>.*</address>|<address>${MANAGER_IP}</address>|' /var/ossec/etc/ossec.conf"
done

echo "🔑 [3/4] Injection des clés d'enrôlement..."
python3 << 'PYEOF'
import subprocess

agents = {
    'target_ftp_medium': '043',
    'target_samba_medium': '042',
    'target_jenkins_medium': '046',
    'target_web_medium': '047'
}

result = subprocess.run(['docker', 'exec', 'single-node-wazuh.manager-1',
    'cat', '/var/ossec/etc/client.keys'], capture_output=True, text=True)
manager_keys = result.stdout

for container, agent_id in agents.items():
    key_line = [l for l in manager_keys.splitlines() if l.startswith(agent_id)]
    if key_line:
        key = key_line[0]
        subprocess.run(['docker', 'exec', '-i', container, 'bash', '-c',
            f'echo "{key}" > /var/ossec/etc/client.keys && chmod 640 /var/ossec/etc/client.keys && chown root:wazuh /var/ossec/etc/client.keys'
        ])
        print(f"  ✅ {container}: clé injectée")
    else:
        print(f"  ❌ {container}: clé non trouvée")
PYEOF

echo "🔄 [4/4] Réveil des agents..."
for container in $CONTAINERS; do
  sudo docker exec $container /var/ossec/bin/wazuh-control restart
done

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
