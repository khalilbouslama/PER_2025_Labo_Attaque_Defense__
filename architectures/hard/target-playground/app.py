from flask import Flask, request, render_template_string
import os

app = Flask(__name__)

# Une page d'accueil innocente
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Python Playground</title>
    <style>
        body { font-family: monospace; background-color: #1a1a1a; color: #00ff00; padding: 50px; }
        input { padding: 10px; width: 300px; }
        button { padding: 10px; cursor: pointer; }
        .output { border: 1px solid #333; padding: 20px; margin-top: 20px; background: #000; }
    </style>
</head>
<body>
    <h1>🐍 Python Template Tester</h1>
    <p>Testez vos variables Jinja2 ici pour voir le rendu en temps réel.</p>
    
    <form method="GET">
        <input type="text" name="code" placeholder="Ex: {{ 7*7 }} ou {{ config }}">
        <button type="submit">Render</button>
    </form>

    {% if result %}
    <div class="output">
        <strong>Result:</strong><br>
        {{ result }}
    </div>
    {% endif %}
</body>
</html>
"""

@app.route('/')
def index():
    code = request.args.get('code')
    
    if code:
        # 🚨 LA FAILLE EST ICI 🚨
        # On injecte l'input directement dans le template string.
        # Si l'utilisateur met {{ 7*7 }}, Jinja2 l'évalue.
        # Si l'utilisateur met du code Python malicieux via MRO, Jinja2 l'exécute.
        try:
            # On simule un rendu dynamique peu sécurisé
            rendered_template = render_template_string(f"{{% set result = 'Wait' %}}{HTML_TEMPLATE}".replace("{{ result }}", code))
            return rendered_template
        except Exception as e:
            return render_template_string(HTML_TEMPLATE.replace("{{ result }}", f"Error: {str(e)}"))
            
    return render_template_string(HTML_TEMPLATE.replace("{{ result }}", "Ready to render."))

if __name__ == '__main__':
    # Lancement sur le port 5000
    app.run(host='0.0.0.0', port=5000)
