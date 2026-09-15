# ============================================================
# INFOS SYSTEME - Pour planification de tâche Windows
# ============================================================

# 1. Chemin du script actuel (fonctionne si lancé via Rscript ou source())
get_script_path <- function() {
  # Cas 1 : lancé depuis la ligne de commande avec Rscript
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    return(normalizePath(sub("^--file=", "", file_arg)))
  }
  
  # Cas 2 : lancé depuis RStudio (source())
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    return(normalizePath(rstudioapi::getSourceEditorContext()$path))
  }
  
  return("Chemin non détecté (lance ce script avec Rscript pour un résultat fiable)")
}

cat("=====================================================\n")
cat("           INFOS POUR PLANIFICATION DE TACHE\n")
cat("=====================================================\n\n")

cat("Chemin du script :\n")
cat(get_script_path(), "\n\n")

cat("Chemin de Rscript.exe (a utiliser dans le Planificateur) :\n")
cat(file.path(R.home("bin"), "Rscript.exe"), "\n\n")

cat("Version de R :\n")
print(getRversion())
cat("\n")

cat("Dossier de travail actuel :\n")
cat(getwd(), "\n\n")

cat("Chemin R.home() complet :\n")
cat(R.home(), "\n")