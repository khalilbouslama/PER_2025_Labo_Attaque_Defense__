<!DOCTYPE html>
<html>
<head>
    <title>TechCorp - Website Status Checker</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card shadow-sm">
        <div class="card-body text-center">
            <h1 class="mb-4">🔧 Outil de Diagnostic Web</h1>
            <p>Vérifiez si vos sites internes ou partenaires sont en ligne.</p>
            
            <form method="POST">
                <div class="input-group mb-3">
                    <input type="text" name="url" class="form-control" placeholder="http://google.com ou http://internal-service" required>
                    <button class="btn btn-primary" type="submit">Vérifier le statut</button>
                </div>
            </form>

            <?php
            if (isset($_POST['url'])) {
                $url = $_POST['url'];
                
                // --- VULNÉRABILITÉ ICI ---
                // On ne nettoie PAS l'entrée ($url). 
                // On l'ajoute directement à la commande curl.
                // Cela permet l'injection avec ";" ou "|" ou "&&"
                $cmd = "curl -s -L --connect-timeout 3 " . $url;
                
                echo "<hr>";
                echo "<h5>Résultat pour : " . htmlspecialchars($url) . "</h5>";
                echo "<div class='text-start bg-dark text-white p-3 rounded'>";
                echo "<pre>" . shell_exec($cmd) . "</pre>";
                echo "</div>";
            }
            ?>
        </div>
    </div>
</div>
</body>
</html>
