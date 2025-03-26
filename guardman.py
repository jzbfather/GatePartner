import os
import importlib
from rootfile  import config_message
from flask import Flask, request


app = Flask(__name__)

# Gestionnaires des messages
config_message (1, app)



def client_verify(client_id):
    if client_id in clients_db:
        client_info = clients_db[client_id]
        
        out_key = request.headers.get("acKey")
        in_key = client_info.get("access_key")
        if out_key and out_key == in_key:
            return True, client_info
        else:
            return False, None
    return False, None



# Dictionnaire de données simulez
clients_db = {
    "xrd95eTcd21": {"name": "Client Alpha", "access_key": "secret12345"},
    "k92PovLw78": {"name": "Client Beta", "access_key": "beta_secret9876"},
    "zXt36YbQ99": {"name": "Client Gamma", "access_key": "gamma_key4567"}
}

def verify_client(client_id):
    if client_id in clients_db:
        client_info = clients_db[client_id]
        
        out_key = request.headers.get("acKey")
        in_key = client_info.get("access_key")
        if out_key and out_key == in_key:
            return True, client_info
        else:
            return False, None
    return False, None

@app.before_request
def check_client():
    publics_services = ['/', '/pawd/']  # Exclure les routes spécifiées
    if request.path in publics_services:
        return  

    path_segments = request.path.strip('/').split('/')
    if len(path_segments) > 0:
        client_id = path_segments[0]
        client_exists, client_info = verify_client(client_id)
        if not client_exists:
            return config_message(2, 401)
        request.client_info = client_info # Ajoute les informations du client à la requête

def register_services(app, directory='routes'):
    # Parcourir le dossier spécifié
    # On ne traite que les fichiers Python, en ignorant __init__.py
    for filename in os.listdir(directory):        
        if filename.endswith('.py') and filename != '__init__.py':
            module_name = filename[:-3]  # Retire l'extension ".py"
            module_path = f"{directory}.{module_name}"
            try:
                # Importer le service dynamiquement sous la variable 'bp' 
                module = importlib.import_module(module_path)
                bp = None
                if hasattr(module, 'bp'):
                    bp = getattr(module, 'bp')
                
                if bp is not None:
                    app.register_blueprint(bp)
                    print(f"Service '{module_name}' enregistré.")
                else:
                    print(f"Aucun service trouvé dans '{module_path}'.")
            except Exception as e:
                print(f"Erreur lors de l'importation du module {module_path}: {e}")

# Enregistrer dynamiquement tous les blueprints depuis le dossier 'routes'
register_services(app)

@app.route("/")
def home():
    return config_message(2, 200, "Bienvenue sur l'application Gatepartner !")
    

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)