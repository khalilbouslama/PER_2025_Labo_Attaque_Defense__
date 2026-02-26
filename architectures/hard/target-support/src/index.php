<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>TechCorp - Support Interne</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .hero { background: #2c3e50; color: white; padding: 2rem; margin-bottom: 2rem; border-radius: 0 0 10px 10px; }
    </style>
</head>
<body>

<div class="container">
    <div class="hero text-center">
        <h1>🛠️ Support TechCorp</h1>
        <p class="lead">Portail de signalement de bugs internes</p>
    </div>

    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow">
                <div class="card-header bg-warning text-dark">
                    <strong>Nouveau Ticket</strong>
                </div>
                <div class="card-body">
                    <p>Utilisez ce formulaire pour soumettre vos scripts de reproduction de bugs.</p>
                    
                    <div class="alert alert-info">
                        <strong>ℹ️ Information :</strong> Notre ingénieur QA, <b>Hakan</b>, passe en revue et <u>exécute</u> automatiquement tous les scripts uploadés (.sh) toutes les minutes pour valider les incidents.
                    </div>

                    <form action="" method="post" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label class="form-label">Description du problème :</label>
                            <textarea class="form-control" rows="2" placeholder="Ex: Le serveur crash quand..."></textarea>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Preuve / Script de test (.sh) :</label>
                            <input type="file" name="fileToUpload" class="form-control" required>
                            <small class="text-muted">Seuls les scripts Bash sont traités automatiquement.</small>
                        </div>

                        <button type="submit" class="btn btn-dark w-100">Envoyer le Ticket</button>
                    </form>

                    <?php
                    if(isset($_FILES["fileToUpload"])) {
                        $target_dir = "/var/www/html/uploads/";
                        $target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
                        $uploadOk = 1;
                        
                        // Vérification basique (c'est un scénario Hard, on ne bloque pas trop l'upload lui-même)
                        if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
                            // IMPORTANT : On rend le fichier exécutable pour que le Bot puisse le lancer
                            chmod($target_file, 0777);
                            echo "<div class='alert alert-success mt-4'>✅ Ticket #".rand(1000,9999)." créé avec succès.<br>Hakan a été notifié et traitera votre fichier sous peu.</div>";
                        } else {
                            echo "<div class='alert alert-danger mt-4'>❌ Erreur lors du téléversement. Vérifiez les droits.</div>";
                        }
                    }
                    ?>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
