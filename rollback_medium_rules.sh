#!/bin/bash
echo "⚠️  Rollback des règles Medium..."

# Restaurer le backup
sudo docker exec single-node-wazuh.manager-1 cp /var/ossec/etc/rules/local_rules.xml.backup_before_medium /var/ossec/etc/rules/local_rules.xml

# Redémarrer Wazuh
sudo docker exec single-node-wazuh.manager-1 /var/ossec/bin/wazuh-control restart

echo "✅ Rollback terminé - Règles Easy restaurées"
