FROM python:3.9-slim

# 1. Installation des outils nécessaires (et du client Docker !)
RUN apt-get update && apt-get install -y \
    curl \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# 2. Création d'un utilisateur non-privilégié "developer"
RUN useradd -m -s /bin/bash developer

# 3. Installation de l'application
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .

# 4. Configuration des permissions pour la faille
# L'astuce : On ne peut pas savoir le GID du groupe docker de l'hôte à l'avance.
# On va utiliser une petite astuce sale : un script de démarrage qui rend le socket accessible.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Flag Utilisateur (Preuve de la RCE/SSTI)
RUN echo "FLAG{HARD_PLAYGROUND_SSTI_USER_ACCESS}" > /home/developer/user_flag.txt
RUN chown developer:developer /home/developer/user_flag.txt

# Flag Root (Preuve du Docker Breakout)
# Note : Avec le socket docker, l'étudiant peut aussi monter le disque de l'hôte,
# mais s'il devient root dans le conteneur, il pourra lire ce fichier.
RUN echo "FLAG{HARD_PLAYGROUND_DOCKER_SOCKET_PWNED}" > /root/root_flag.txt

# 5. On expose le port
EXPOSE 5000

# 6. On lance via le script d'entrée
ENTRYPOINT ["/entrypoint.sh"]
