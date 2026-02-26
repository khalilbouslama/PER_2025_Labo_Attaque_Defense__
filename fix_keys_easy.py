import subprocess
agents = {
    'target_ftp_easy': '057',
    'target_samba_easy': '058',
    'target_apache_easy': '059',
    'target_jenkins_easy': '060'
}
# Lire toutes les cles du manager
result = subprocess.run(['docker', 'exec', 'single-node-wazuh.manager-1',
    'cat', '/var/ossec/etc/client.keys'], capture_output=True, text=True)
manager_keys = result.stdout
for container, agent_id in agents.items():
    print(f"Fix keys {container}...")
    key_line = [l for l in manager_keys.splitlines() if l.startswith(agent_id)]
    if key_line:
        key = key_line[0]
        subprocess.run(['docker', 'exec', '-i', container, 'bash', '-c',
            f'echo "{key}" > /var/ossec/etc/client.keys && chmod 640 /var/ossec/etc/client.keys && chown root:wazuh /var/ossec/etc/client.keys && /var/ossec/bin/wazuh-control restart'
        ])
        print(f"  Cle: {key}")
    else:
        print(f"  ERREUR: cle non trouvee pour {agent_id}")
print("Done!")
