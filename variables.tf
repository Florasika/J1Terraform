# ============================================================
#  JOUR 1 / 10 — Variables Terraform
#  Rendent le code réutilisable et paramétrable
# ============================================================

variable "nom_projet" {
  description = "Nom du projet data"
  type        = string
  default     = "etl_portfolio"

  validation {
    condition     = length(var.nom_projet) >= 3
    error_message = "Le nom du projet doit avoir au moins 3 caractères."
  }
}

variable "environnement" {
  description = "Environnement cible : dev, staging, prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environnement)
    error_message = "Environnement doit être : dev, staging, ou prod."
  }
}

variable "version_app" {
  description = "Version de l'application"
  type        = string
  default     = "1.0.0"
}

variable "db_host" {
  description = "Hostname de la base de données"
  type        = string
  default     = "localhost"
}

variable "db_port" {
  description = "Port de la base de données"
  type        = number
  default     = 5432

  validation {
    condition     = var.db_port > 0 && var.db_port < 65536
    error_message = "Le port doit être entre 1 et 65535."
  }
}

variable "pipeline_schedule" {
  description = "Schedule du pipeline (format cron)"
  type        = string
  default     = "0 6 * * *"   # tous les jours à 6h
}

variable "tags" {
  description = "Tags à appliquer aux ressources"
  type        = map(string)
  default     = {
    projet  = "data-portfolio"
    auteur  = "sung"
    serie   = "10-days-terraform"
  }
}
