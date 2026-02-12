#!/bin/bash
echo "🚀 Déploiement des règles Medium..."

# Copier le fichier dans le conteneur
sudo docker cp documentation/local_rules_medium.xml single-node-wazuh.manager-1:/tmp/

# Ajouter les règles Medium au fichier existant
sudo docker exec single-node-wazuh.manager-1 bash -c "cat /tmp/local_rules_medium.xml >> /var/ossec/etc/rules/local_rules.xml"

# Vérifier la syntaxe
echo "🔍 Vérification de la syntaxe..."
sudo docker exec single-node-wazuh.manager-1 /var/ossec/bin/wazuh-logtest-legacy -t

# Redémarrer Wazuh
echo "♻️  Redémarrage de Wazuh..."
sudo docker exec single-node-wazuh.manager-1 /var/ossec/bin/wazuh-control restart

echo "✅ Déploiement terminé !"
