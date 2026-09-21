# ============================================================
#  JOUR 1 / 10 — Outputs Terraform
#  Exposent des valeurs après terraform apply
# ============================================================

output "chemin_config" {
  description = "Chemin du fichier de configuration généré"
  value       = local_file.config_pipeline.filename
}

output "chemin_env" {
  description = "Chemin du fichier .env généré"
  value       = local_sensitive_file.env_file.filename
  sensitive   = true   # masqué dans les logs CI/CD
}

output "nom_base_de_donnees" {
  description = "Nom de la base de données calculé"
  value       = "${var.nom_projet}_${var.environnement}"
}

output "resume_config" {
  description = "Résumé de la configuration déployée"
  value = {
    projet        = var.nom_projet
    environnement = var.environnement
    version       = var.version_app
    db_host       = var.db_host
    schedule      = var.pipeline_schedule
    fichiers_crees = [
      local_file.config_pipeline.filename,
      local_file.readme_projet.filename,
    ]
  }
}
