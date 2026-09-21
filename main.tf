# ============================================================
#  JOUR 1 / 10 — Terraform : Introduction
#  Provider : local (pas de compte cloud nécessaire)
#  Concepts : resource, variable, output, data source
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# ── Provider ─────────────────────────────────────────────────
# Le provider "local" permet de créer des fichiers sur la machine
# Pas de credentials nécessaires — parfait pour apprendre
provider "local" {}

# ── RESOURCE 1 : Créer un fichier de configuration ───────────
# Syntaxe : resource "TYPE" "NOM_LOCAL" { ... }
# TYPE     = type de ressource (local_file, aws_instance...)
# NOM_LOCAL= identifiant dans le code Terraform (pas le nom du fichier)
resource "local_file" "config_pipeline" {
  filename        = "${path.module}/output/config_pipeline.json"
  content         = jsonencode({
    projet         = var.nom_projet
    environnement  = var.environnement
    version        = var.version_app
    base_de_donnees = {
      host = var.db_host
      port = var.db_port
      nom  = "${var.nom_projet}_${var.environnement}"
    }
    pipeline = {
      schedule     = var.pipeline_schedule
      max_retries  = 3
      timeout_min  = 30
    }
    cree_par      = "Terraform"
    cree_le       = timestamp()
  })
  file_permission = "0644"
}

# ── RESOURCE 2 : Créer un fichier README ─────────────────────
resource "local_file" "readme_projet" {
  filename = "${path.module}/output/README_projet.md"
  content  = templatefile("${path.module}/templates/readme.tpl", {
    nom_projet    = var.nom_projet
    environnement = var.environnement
    version       = var.version_app
    db_host       = var.db_host
  })
}

# ── RESOURCE 3 : Fichier .env pour le pipeline ───────────────
resource "local_sensitive_file" "env_file" {
  filename        = "${path.module}/output/.env"
  content         = <<-EOT
    # Fichier généré par Terraform — NE PAS COMMITTER
    PROJET=${var.nom_projet}
    ENV=${var.environnement}
    VERSION=${var.version_app}
    DB_HOST=${var.db_host}
    DB_PORT=${var.db_port}
    DB_NAME=${var.nom_projet}_${var.environnement}
    PIPELINE_SCHEDULE=${var.pipeline_schedule}
  EOT
  file_permission = "0600"   # lecture/écriture seulement pour le propriétaire
}

# ── DATA SOURCE : Lire un fichier existant ───────────────────
# data = lire une ressource EXISTANTE (pas la créer)
data "local_file" "gitignore" {
  filename = "${path.module}/.gitignore_template"
}
