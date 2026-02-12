#!/bin/bash
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
MANAGER="single-node-wazuh.manager-1"
CONTAINERS="target_ftp_easy target_samba_easy target_apache_easy target_jenkins_easy"
AGENT_NAMES="target-ftp-easy target-samba-easy target-apache-easy target-jenkins-easy"

banner() { echo -e "\n${CYAN}============================================${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}============================================${NC}\n"; }

unblock_ips() {
    echo -e "${YELLOW}[1/4] Déblocage des IPs...${NC}"
    for c in target_samba_easy target_apache_easy target_ftp_easy; do
        sudo docker exec $c /var/ossec/active-response/bin/firewall-drop delete - 172.19.0.1 2>/dev/null || true
    done
    echo -e "${GREEN}  ✅ IPs débloquées${NC}"
}

clean_agent_logs() {
    echo -e "${YELLOW}[2/4] Nettoyage des logs agents...${NC}"
    for c in $CONTAINERS; do
        sudo docker exec $c bash -c '
            > /var/log/auth.log 2>/dev/null; > /var/log/syslog 2>/dev/null
            > /var/log/samba/log.smbd 2>/dev/null; > /var/log/apache2/access.log 2>/dev/null
            > /var/log/vsftpd.log 2>/dev/null; > /var/ossec/logs/active-responses.log 2>/dev/null
        ' 2>/dev/null || true
    done
    echo -e "${GREEN}  ✅ Logs agents nettoyés${NC}"
}

clean_manager_logs() {
    echo -e "${YELLOW}[3/4] Nettoyage des logs manager...${NC}"
    sudo docker exec $MANAGER bash -c '
        > /var/ossec/logs/alerts/alerts.log; > /var/ossec/logs/alerts/alerts.json
        > /var/ossec/logs/archives/archives.log; > /var/ossec/logs/archives/archives.json
        > /var/ossec/logs/active-responses.log
    ' 2>/dev/null || true
    echo -e "${GREEN}  ✅ Logs manager nettoyés${NC}"
}

restart_agents() {
    echo -e "${YELLOW}[4/4] Redémarrage des agents...${NC}"
    for c in $CONTAINERS; do
        sudo docker exec $c /var/ossec/bin/wazuh-control restart 2>/dev/null || true
    done
    sleep 15
    sudo docker exec $MANAGER /var/ossec/bin/agent_control -l | grep -E "easy|target-web"
}

remove_old_agents() {
    echo -e "${YELLOW}[*] Suppression des anciens agents Easy du manager...${NC}"
    # Récupérer les IDs des agents easy
    AGENT_IDS=$(sudo docker exec $MANAGER /var/ossec/bin/agent_control -l | grep "easy" | awk '{print $2}' | tr -d ',')
    for id in $AGENT_IDS; do
        sudo docker exec $MANAGER /var/ossec/bin/manage_agents -r $id <<< "y" 2>/dev/null || true
        echo -e "${GREEN}  ✅ Agent $id supprimé${NC}"
    done
}

reregister_agents() {
    echo -e "${YELLOW}[*] Réenregistrement des agents...${NC}"
    for c in $CONTAINERS; do
        sudo docker exec $c bash -c 'rm -f /var/ossec/etc/client.keys && /var/ossec/bin/wazuh-control restart' 2>/dev/null || true
    done
    echo -e "${YELLOW}[*] Attente 30s pour l'enregistrement...${NC}"
    sleep 30
    sudo docker exec $MANAGER /var/ossec/bin/agent_control -l | grep -E "easy|target-web"
}

clean_kali() {
    rm -f ~/note_service.txt ~/flag.txt ~/hydra.restore 2>/dev/null || true
    rm -f ~/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/easy/note_service.txt 2>/dev/null || true
    rm -f ~/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/easy/hydra.restore 2>/dev/null || true
}

case "${1:---logs}" in
    --full)
        banner "RESET COMPLET (Rebuild)"
        echo -e "${YELLOW}⚠️  Ceci va reconstruire tous les conteneurs Easy.${NC}"
        read -p "Continuer ? (y/n) " -n 1 -r; echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Supprimer les anciens agents AVANT le rebuild
            remove_old_agents
            cd ~/Desktop/PER_2025_Labo_Attaque_Defense__/architectures/easy
            sudo docker-compose down && sudo docker-compose up -d --build
            echo -e "${YELLOW}[*] Attente 60s...${NC}"; sleep 60
            sudo docker network connect easy_net_easy $MANAGER 2>/dev/null || true
            echo -e "${YELLOW}[*] Attente agents 30s...${NC}"; sleep 30
            sudo docker exec $MANAGER /var/ossec/bin/agent_control -l | grep -E "easy|target-web"
            echo -e "${GREEN}✅ Reset complet terminé !${NC}"
        fi ;;
    --logs)
        banner "RÉINITIALISATION LOGS + DÉBLOCAGE"
        unblock_ips; clean_agent_logs; clean_manager_logs; clean_kali; restart_agents
        echo -e "${GREEN}✅ Environnement prêt pour un nouvel exercice !${NC}" ;;
    --unblock)
        banner "DÉBLOCAGE DES IPS"
        unblock_ips ;;
    --reregister)
        banner "RÉENREGISTREMENT DES AGENTS"
        remove_old_agents; reregister_agents ;;
    *) echo "Usage: $0 [--full|--logs|--unblock|--reregister]"; exit 1 ;;
esac
