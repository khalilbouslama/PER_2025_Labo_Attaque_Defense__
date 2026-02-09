FROM jenkins/jenkins:lts-jdk17

# On passe en ROOT pour l'installation
USER root

# 1. Installation des outils (gnupg est requis pour la clé)
RUN apt-get update && apt-get install -y \
    gcc \
    netcat-openbsd \
    curl \
    gnupg \
    iproute2 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation de l'agent Wazuh (CORRECTION : Méthode moderne sans apt-key)
RUN mkdir -p /etc/apt/keyrings && \
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /etc/apt/keyrings/wazuh.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && apt-get install -y wazuh-agent

# CRÉATION DU USER VULNÉRABLE (admin / jenkins123)
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy

# 3. Faille "Jenkins Script Console" (Sécurité désactivée)
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# 4. Faille "PATH Hijacking" (Binaire SUID vulnérable)
COPY sysinfo.c /tmp/sysinfo.c
RUN gcc /tmp/sysinfo.c -o /usr/bin/sysinfo
RUN chown root:root /usr/bin/sysinfo && \
    chmod 4755 /usr/bin/sysinfo && \
    rm /tmp/sysinfo.c

# LE FLAG FINAL (ROOT ONLY) - On le fait tant qu'on est Root
RUN echo "FLAG{MEDIUM_JENKINS_SUID_ROOT}" > /root/root_flag.txt
RUN chmod 600 /root/root_flag.txt

# 5. Configuration finale - On copie et rend exécutable tant qu'on est Root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# === C'EST ICI QU'ON DEVIENT L'UTILISATEUR LIMITÉ (TOUT À LA FIN) ===
USER jenkins

EXPOSE 8080 50000

ENTRYPOINT ["/entrypoint.sh"]
