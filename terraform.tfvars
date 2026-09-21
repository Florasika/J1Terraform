# ============================================================
#  Valeurs des variables pour l'environnement DEV
#  Fichier : terraform.tfvars (chargé automatiquement)
#  NE PAS committer si contient des secrets
# ============================================================

nom_projet        = "etl_portfolio"
environnement     = "dev"
version_app       = "1.0.0"
db_host           = "localhost"
db_port           = 5432
pipeline_schedule = "0 6 * * *"

tags = {
  projet = "data-portfolio"
  auteur = "sung"
  serie  = "10-days-terraform"
}
