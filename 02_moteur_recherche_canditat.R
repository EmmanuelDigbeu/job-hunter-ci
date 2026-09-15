# ==========================================
# JOB HUNTER CI
# Script 02 V2 : Moteur de recherche candidat
# ==========================================
rm(list = setdiff(ls(envir = .GlobalEnv), "debut"))

print("================================")
print("JOB HUNTER CI - MOTEUR RECHERCHE V2")
print("================================")

# ==========================================
# LIBRAIRIES
# ==========================================
library(tidyverse)
library(stringr)
library(lubridate)

# ==========================================
# CHARGEMENT PROFIL CANDIDAT
# ==========================================
if(!file.exists("Data/profil_candidat.RData")){
  stop("Profil candidat introuvable. Lance Script 01 avant.")
}
load("Data/profil_candidat.RData")
print("Profil candidat chargé")

# ==========================================
# DATE COLLECTE
# ==========================================
date_collecte <- Sys.Date()
print(
  paste(
    "Date collecte :",
    date_collecte
  )
)

# ==========================================
# GENERATION MOTS CLES METIERS
# ==========================================
mots_cles_metiers <- c(
  profil_candidat$metiers_cibles,
  "Data Analyst",
  "BI Analyst",
  "Business Analyst",
  "Reporting Analyst",
  "Performance Analyst",
  "Data Engineer Junior",
  "Data Scientist Junior",
  "Analytics Analyst",
  "Business Intelligence Analyst",
  "PMO Data",
  "Data Officer",
  "Data Consultant",
  "Digital Analyst"
)

# ==========================================
# COMPETENCES TECHNIQUES
# ==========================================
mots_cles_competences <- c(
  profil_candidat$competences,
  "SQL",
  "Python",
  "R",
  "Power BI",
  "DAX",
  "Power Query",
  "Dashboard",
  "KPI",
  "Reporting",
  "Excel",
  "ETL",
  "Data Warehouse",
  "Machine Learning",
  "Analyse statistique"
)

# ==========================================
# MOTS CLES FINAUX
# ==========================================
mots_cles <- unique(
  c(
    mots_cles_metiers,
    mots_cles_competences
  )
)
print(
  paste(
    "Nombre mots clés générés :",
    length(mots_cles)
  )
)

# ==========================================
# MOTS A EXCLURE
# ==========================================
mots_exclus <- c(
  "Data Entry",
  "Saisie de données",
  "Opérateur de saisie",
  "Assistant administratif",
  "Secrétaire",
  "Stage non rémunéré",
  "Commercial terrain"
)
print(
  paste(
    "Nombre exclusions :",
    length(mots_exclus)
  )
)

# ==========================================
# PATTERNS POUR RECHERCHE
# ==========================================
pattern_recherche <- paste(
  mots_cles,
  collapse = "|"
)
pattern_exclusion <- paste(
  mots_exclus,
  collapse = "|"
)

# ==========================================
# STRUCTURE BASE OFFRES
# ==========================================
offres <- data.frame(
  id_offre = integer(),
  date_collecte = as.Date(character()),
  poste = character(),
  entreprise = character(),
  localisation = character(),
  contrat = character(),
  experience = character(),
  competences = character(),
  description = character(),
  lien = character(),
  source = character(),
  score = numeric(),
  statut = character(),
  stringsAsFactors = FALSE
)

# ==========================================
# SAUVEGARDE CONFIGURATION
# ==========================================
save(
  mots_cles,
  mots_exclus,
  pattern_recherche,
  pattern_exclusion,
  offres,
  file = "Data/config_recherche.RData"
)
print("--------------------------------")
print(
  "Configuration recherche sauvegardée"
)
print(
  "Fichier : Data/config_recherche.RData"
)
print(
  "JOB HUNTER CI - MOTEUR V2 PRET"
)
print("--------------------------------")