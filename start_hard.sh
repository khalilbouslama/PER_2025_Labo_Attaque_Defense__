#!/bin/bash

# ============================================================
# SCRIPT DE LANCEMENT - ARCHITECTURE HARD (DOUBLE PIVOT)
# ============================================================

# Définition des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 [0/3] Nettoyage des environnements précédents (Easy & Medium)...${NC}"
# On arrête les autres labos pour éviter les conflits d'IP ou de noms
cd ~/Bureau/PER/architectures/easy
sudo docker-compose down 2>/dev/null
cd ~/Bureau/PER/architectures/medium
sudo docker-compose down 2>/dev/null
cd ~/Bureau/PER/wazuh-docker/single-node
# On garde Wazuh allumé s'il l'est déjà, sinon on le lance
if [ -z "$(sudo docker ps -q -f name=wazuh.manager)" ]; then
    echo -e "${BLUE}🔵 [1/3] Démarrage du Commissariat (Wazuh Blue Team)...${NC}"
    sudo docker-compose up -d
    echo "   ⏳ Attente de 30 secondes pour l'initialisation de Wazuh..."
    sleep 30
else
    echo -e "${GREEN}✅ Wazuh tourne déjà.${NC}"
fi

echo -e "${RED}🔴 [2/3] Démarrage du Labo HARD (Mode Guerre)...${NC}"
cd ~/Bureau/PER/architectures/hard
sudo docker-compose up -d --build

echo -e "${GREEN}🔄 [3/3] Vérification des systèmes...${NC}"
# (Optionnel) Si on ajoute Wazuh plus tard, on décommentera ces lignes :
# sudo docker exec target-web-hard service wazuh-agent restart
# sudo docker exec target-jenkins-hard service wazuh-agent restart

echo "============================================================"
echo -e "${RED}🔥 LABO HARD PRÊT ! 🔥${NC}"
echo "============================================================"
echo "📊 Dashboard Wazuh : https://127.0.0.1"
echo "💻 Gitea (Public)  : http://localhost:3000"
echo "------------------------------------------------------------"
echo -e "🗡️  ATTAQUANT (Kali) : ${GREEN}ssh root@127.0.0.1 -p 2223${NC} (Mdp: root)"
echo "------------------------------------------------------------"
echo "🎯 CIBLES VISIBLES :"
echo "   1. Web Gateway    : http://172.21.0.40"
echo "   2. Gitea Server   : http://172.21.0.41"
echo "------------------------------------------------------------"
echo "⚠️  NOTE : Les réseaux 172.23.0.0 et 172.25.0.0 sont masqués."
echo "          Vous devrez pivoter pour les atteindre."
echo "============================================================"
