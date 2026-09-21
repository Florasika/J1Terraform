# 🏗️ Jour 1 / 10 — Terraform : Introduction

> **Série : 10 Days of Terraform** · Jour 1/10  
> Concepts : Provider · Resource · Variable · Output · Data Source · init/plan/apply

---

## 📁 Fichiers du projet

```
day-01-introduction/
│
├── main.tf                 ← Resources : 3 fichiers générés
├── variables.tf            ← Déclaration des variables
├── outputs.tf              ← Valeurs exposées après apply
├── terraform.tfvars        ← Valeurs des variables (dev)
├── templates/
│   └── readme.tpl          ← Template pour le README généré
├── .gitignore_template     ← Fichier lu par data source
├── output/                 ← Créé par Terraform (vide au départ)
└── README.md
```

---

## 🧠 C'est quoi Terraform ?

```
Terraform = Infrastructure as Code (IaC)
→ Décrire l'infrastructure en code HCL
→ Terraform crée, modifie, détruit les ressources
→ Le code est versionnable, réutilisable, documenté

Sans Terraform : cliquer dans des interfaces web
Avec Terraform : git commit + terraform apply
```

---

## 🚀 ÉTAPE 1 — Installer Terraform

```bash
# Mac (Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux (Ubuntu/Debian)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows (Chocolatey)
choco install terraform

# Vérifier
terraform version
# → Terraform v1.7.x
```

---

## 🚀 ÉTAPE 2 — Préparer les fichiers

```bash
mkdir -p jour1-terraform/templates
mkdir -p jour1-terraform/output
cd jour1-terraform/

# Copier les fichiers depuis le dépôt :
# main.tf              → racine
# variables.tf         → racine
# outputs.tf           → racine
# terraform.tfvars     → racine
# readme_template.tpl  → templates/readme.tpl
# gitignore_template   → .gitignore_template

# Créer le .gitignore
cat > .gitignore << 'EOF'
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
*.tfvars
!terraform.tfvars.example
output/.env
EOF
```

---

## 🔑 ÉTAPE 3 — Les 4 fichiers HCL expliqués

### main.tf — les resources

```hcl
# Syntaxe d'une resource :
# resource "TYPE_PROVIDER" "NOM_LOCAL" {
#   attribut = valeur
# }

resource "local_file" "config_pipeline" {
  filename = "${path.module}/output/config_pipeline.json"
  content  = jsonencode({
    projet = var.nom_projet        # référence une variable
    env    = var.environnement
  })
}
```

### variables.tf — les variables

```hcl
variable "nom_projet" {
  description = "Nom du projet"
  type        = string    # string, number, bool, list, map, object
  default     = "etl_portfolio"

  validation {            # validation optionnelle
    condition     = length(var.nom_projet) >= 3
    error_message = "Au moins 3 caractères."
  }
}
```

### outputs.tf — les sorties

```hcl
output "nom_base" {
  description = "Nom de la BDD calculé"
  value       = "${var.nom_projet}_${var.environnement}"
  sensitive   = true   # masqué dans les logs
}
```

### terraform.tfvars — les valeurs

```hcl
nom_projet    = "etl_portfolio"
environnement = "dev"
db_port       = 5432
```

---

## 🚀 ÉTAPE 4 — terraform init

```bash
terraform init

# Résultat :
# Initializing the backend...
# Initializing provider plugins...
# - Finding hashicorp/local versions matching "~> 2.4"...
# - Installing hashicorp/local v2.4.1...
# Terraform has been successfully initialized!

# Crée le dossier .terraform/ avec les providers téléchargés
ls .terraform/providers/
```

---

## 🚀 ÉTAPE 5 — terraform plan

```bash
terraform plan

# Résultat :
# Terraform will perform the following actions:
#
#   # local_file.config_pipeline will be created
#   + resource "local_file" "config_pipeline" {
#       + content  = (known after apply)
#       + filename = "./output/config_pipeline.json"
#     }
#
#   # local_file.readme_projet will be created
#   + resource "local_file" "readme_projet" { ... }
#
#   # local_sensitive_file.env_file will be created
#   + resource "local_sensitive_file" "env_file" { ... }
#
# Plan: 3 to add, 0 to change, 0 to destroy.

# Sauvegarder le plan
terraform plan -out=tfplan
```

---

## 🚀 ÉTAPE 6 — terraform apply

```bash
# Appliquer (demande confirmation)
terraform apply

# Ou appliquer sans confirmation (CI/CD)
terraform apply -auto-approve

# Résultat :
# Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
#
# Outputs:
# chemin_config    = "./output/config_pipeline.json"
# nom_base_de_donnees = "etl_portfolio_dev"

# Vérifier les fichiers créés
ls output/
cat output/config_pipeline.json
cat output/README_projet.md
```

---

## 🔑 ÉTAPE 7 — Le state Terraform

```bash
# terraform.tfstate = état actuel de l'infrastructure
# Terraform sait ce qu'il a créé grâce à ce fichier

cat terraform.tfstate

# Voir l'état formaté
terraform show

# Lister les ressources dans le state
terraform state list
# → local_file.config_pipeline
# → local_file.readme_projet
# → local_sensitive_file.env_file

# Voir une ressource spécifique
terraform state show local_file.config_pipeline
```

---

## 🚀 ÉTAPE 8 — Modifier et réappliquer

```bash
# Modifier une variable dans terraform.tfvars
# environnement = "staging"

terraform plan
# → 3 to change (les fichiers vont être recréés)

terraform apply -auto-approve
# → fichiers régénérés avec environnement=staging
```

---

## 🚀 ÉTAPE 9 — Passer des variables en ligne de commande

```bash
# Surcharger une variable
terraform apply -var="environnement=prod" -auto-approve

# Ou depuis un fichier de variables spécifique
terraform apply -var-file="prod.tfvars" -auto-approve
```

---

## 🚀 ÉTAPE 10 — Détruire les ressources

```bash
# Voir ce qui sera détruit
terraform plan -destroy

# Détruire (avec confirmation)
terraform destroy

# Sans confirmation
terraform destroy -auto-approve

# → Supprime les 3 fichiers générés
# → terraform.tfstate est mis à jour
```

---

## 💡 Les 3 commandes essentielles

| Commande | Action |
|----------|--------|
| `terraform init` | Télécharger les providers |
| `terraform plan` | Prévisualiser les changements |
| `terraform apply` | Appliquer les changements |
| `terraform destroy` | Supprimer les ressources |
| `terraform show` | Voir l'état actuel |
| `terraform fmt` | Formater le code HCL |
| `terraform validate` | Valider la syntaxe |

---



---

⭐ **Si ce projet t'aide, mets une étoile !**
