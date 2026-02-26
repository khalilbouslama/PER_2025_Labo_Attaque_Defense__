<?php
$file = $_GET['page'];

if(isset($file))
{
    // 🚨 FAILLE LFI (Local File Inclusion)
    // On inclut directement le fichier demandé sans vérifier s'il est autorisé.
    // L'attaquant peut faire ?page=../../../../etc/passwd
    // Ou pire : ?page=/var/log/apache2/access.log (Log Poisoning)
    include("$file");
}
else
{
    echo "<h1>🚀 Rocket Documentation</h1>";
    echo "<p>Select a guide:</p>";
    echo "<ul>";
    echo "<li><a href='?page=intro.txt'>Introduction</a></li>";
    echo "<li><a href='?page=specs.txt'>Specifications</a></li>";
    echo "</ul>";
}
?>
