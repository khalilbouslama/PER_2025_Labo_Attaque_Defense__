# 🚀 PER 2025: Labo Attaque/Défense

Ce projet est un laboratoire de cybersécurité pour le M2.

Il utilise Docker pour lancer deux machines :
* **Un attaquant :** `Kali Linux`
* **Une victime :** `DVWA` (un site web vulnérable)

---

## 🛠️ 1. Prérequis

Avant de commencer, vous avez besoin de **2 choses** :

1.  **Git** (pour copier le projet)
2.  **Docker Desktop** (pour lancer les machines)
    * ➡️ **Télécharger Docker Desktop ici :** [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

> **TRÈS IMPORTANT :** Une fois Docker Desktop installé, **lancez-le**. Assurez-vous que l'icône de la baleine 🐳 est verte et stable avant de continuer.

---

## 🚀 2. Démarrer le Labo (Attaquant + Victime)

Ouvrez votre terminal (PowerShell) et suivez ces 3 commandes :

1.  **Clonez le projet :**
    ```bash
    git clone [https://github.com/khalilbouslama/PER2025-051-Infrastructure-pour-un-laboratoire-d-apprentissage-attaque-d-fense-du-hacking-thique.git](https://github.com/khalilbouslama/PER2025-051-Infrastructure-pour-un-laboratoire-d-apprentissage-attaque-d-fense-du-hacking-thique.git)
    ```

2.  **Entrez dans le dossier :**
    ```bash
    # (Le nom est long, utilisez la touche TAB pour auto-compléter)
    cd PER2025-051-Infrastructure-pour-un-laboratoire-d-apprentissage-attaque-d-fense-du-hacking-thique
    ```

3.  **Lancez le labo :**
    ```bash
    docker compose up -d
    ```

Docker va tout télécharger et démarrer. Patientez 1 ou 2 minutes.

---

## 🕹️ 3. Comment Utiliser le Labo

Votre labo est prêt !

#### ✅ Pour voir la Victime (DVWA)
1.  Ouvrez votre navigateur (Chrome, Firefox, ...).
2.  Allez sur [`http://localhost`](http://localhost).
3.  Vous verrez la page de login de DVWA.

#### ✅ Pour entrer chez l'Attaquant (Kali)
1.  Ouvrez un terminal.
2.  Tapez cette commande pour entrer dans la machine Kali :

    ```bash
    # Astuce : Tapez "docker exec -it per" puis appuyez sur la touche TAB
    docker exec -it per2025-051-infrastructure-pour-un-laboratoire-d-apprentissage-attaque-d-fense-du-hacking-thique-kali-1 bash
    ```
3.  Votre terminal change et affiche `root@...:/#`. **Vous êtes maintenant dans Kali !**
4.  Vérifiez la connexion en "pingant" la victime (son nom est `dvwa`) :
    ```bash
    # (Dans le terminal Kali)
    ping dvwa
    ```

---

## 🛡️ 4. (Optionnel) Démarrer la Défense (Wazuh)

Wazuh (notre SIEM) est un projet séparé.

1.  Ouvrez un **nouveau terminal** (ne fermez pas l'autre).
2.  Clonez le dépôt officiel de Wazuh :
    ```bash
    git clone [https://github.com/wazuh/wazuh-docker.git](https://github.com/wazuh/wazuh-docker.git)
    ```
3.  Entrez dans le bon dossier :
    ```bash
    cd wazuh-docker/single-node
    ```
4.  Lancez Wazuh :
    ```bash
    docker compose up -d
    ```
5.  Accédez au dashboard sur [`https://localhost`](https://localhost) (Login: `admin`, Pass: `SecretPassword`).

---

## 🧹 5. Comment Tout Arrêter

Quand vous avez fini, ouvrez les terminaux de chaque projet et tapez :

1.  **Pour arrêter le labo (Kali + DVWA) :**
    ```bash
    # (Dans le dossier PER2025-051...)
    docker compose down
    ```
2.  **Pour arrêter Wazuh :**
    ```bash
    # (Dans le dossier wazuh-docker/single-node)
    docker compose down
    ```