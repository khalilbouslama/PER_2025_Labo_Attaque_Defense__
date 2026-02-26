#!/bin/bash

# Dossier surveillé
UPLOAD_DIR="/var/www/html/uploads"

echo "[BOT] Hakan démarre son service de vérification..."

while true; do
    # Vérifie si le dossier n'est pas vide
    if [ "$(ls -A $UPLOAD_DIR)" ]; then
        
        # Pour chaque fichier trouvé
        for file in "$UPLOAD_DIR"/*; do
            if [ -f "$file" ]; then
                echo "[BOT] Hakan analyse le ticket : $file"
                
                # --- LA FAILLE EST ICI ---
                # Hakan exécute naïvement le script bash
                # On utilise 'timeout' pour éviter que le bot ne bloque si c'est un reverse shell
                # Cela permet au script de continuer à tourner
                timeout 10s /bin/bash "$file"
                
                # Nettoyage : suppression de la preuve après "analyse"
                rm -f "$file"
                echo "[BOT] Ticket fermé, fichier supprimé."
            fi
        done
    fi
    
    # Hakan fait une pause de 5 secondes avant de revérifier
    sleep 5
done
