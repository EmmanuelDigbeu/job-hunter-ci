# ==========================================
# JOB HUNTER CI
# Script 03_2_2 : Nettoyage offres collectées
# VERSION CORRIGEE (lecture robuste + encodage)
# ==========================================

rm(list = ls())

print("================================")
print("JOB HUNTER CI - NETTOYAGE OFFRES")
print("================================")

setwd("~/CV Ange Emmanuel/JOB_HUNTER_CI")

# ==========================================
# PACKAGES
# ==========================================

library(dplyr)
library(stringr)

# ==========================================
# CHARGEMENT DONNEES
# ==========================================

fichier_entree <- "Data/offres_a_analyser.csv"

if(!file.exists(fichier_entree)){
  
  stop(
    "Fichier Data/offres_a_analyser.csv introuvable. Lance d'abord Scripts/03_2_1_collecte_offres_multi_sources.R"
  )
  
}

if(file.info(fichier_entree)$size == 0){
  
  stop(
    "Fichier Data/offres_a_analyser.csv est vide. Aucune offre n'a été collectée à l'étape précédente."
  )
  
}

offres <- read.csv(
  fichier_entree,
  stringsAsFactors = FALSE
)

print(
  paste(
    "Nombre liens initiaux :",
    nrow(offres)
  )
)

# ==========================================
# SUPPRESSION DOUBLONS
# ==========================================

if(nrow(offres) > 0 && "lien" %in% names(offres)){
  
  
  offres <- offres %>%
    
    filter(
      !is.na(lien)
    ) %>%
    
    distinct(
      lien,
      .keep_all = TRUE
    )
  
  
}

print(
  paste(
    "Après suppression doublons :",
    nrow(offres)
  )
)

# ==========================================
# FILTRE MOTS CLES OFFRES
# ==========================================

motifs_offres <- c(
  
  "emploi",
  "job",
  "career",
  "careers",
  "vacancy",
  "vacancies",
  "position",
  "recruit",
  "recruitment",
  
  # CORRIGE : mots-clés manquants, très utilisés par les sites
  # francophones ivoiriens (ex : /offre/12345, /offres-emploi/...)
  "offre",
  "offres"
  
)

pattern <- paste(
  motifs_offres,
  collapse="|"
)

if(nrow(offres) > 0){
  
  
  offres <- offres %>%
    
    filter(
      
      str_detect(
        
        str_to_lower(lien),
        
        pattern
        
      )
      
    )
  
  
}

print(
  paste(
    "Après filtre mots clés offres :",
    nrow(offres)
  )
)

# ==========================================
# FILTRE URL RECRUTEMENT REEL
# ==========================================

criteres_recrutement <- c(
  
  "/job/",
  "/jobs/",
  "/career/",
  "/careers/",
  "/vacancy/",
  "/vacancies/",
  "/recruitment/",
  "/position/",
  
  # CORRIGE : les URLs francophones composées type
  # "offres-emploi/12345-titre" ne contiennent pas "/emploi/"
  # isolé avec des slashs des deux côtés. On ajoute des patterns
  # plus permissifs pour ne pas les rejeter à tort.
  "/offre/",
  "/offres/",
  "offre-emploi",
  "offres-emploi",
  "/job-",
  "/emploi-",
  "/annonce/",
  "/annonces/"
  
)

pattern_job <- paste(
  
  criteres_recrutement,
  
  collapse="|"
  
)

if(nrow(offres) > 0){
  
  
  offres <- offres %>%
    
    filter(
      
      str_detect(
        
        str_to_lower(lien),
        
        pattern_job
        
      )
      
    )
  
  
}

print(
  paste(
    "Après validation URL recrutement :",
    nrow(offres)
  )
)

# ==========================================
# EXCLUSION PAGES INUTILES
# ==========================================

exclusions <- c(
  
  "login",
  "signup",
  "register",
  "contact",
  "about",
  "terms",
  "privacy",
  "fraud",
  "beware",
  "home",
  "faq",
  
  # Faux positifs identifiés : pages de statistiques de salaires
  # et liens de suggestions Indeed (pas de vraies offres)
  "salaries",
  "salary",
  "campaignid=serp-more",
  
  # Faux positifs identifiés : pages de CATEGORIE Projobivoire
  # (ex: /emploi-type/stage/) qui listent plusieurs offres,
  # ce ne sont pas des annonces individuelles
  "emploi-type",
  
  # Faux positifs identifiés : pages de compte/formulaire JobIvoire
  # (vérification OTP, étapes de workspace) qui ne sont pas des offres
  "workspace/jobs/step",
  "verification",
  "otp"
  
)

pattern_exclusion <- paste(
  
  exclusions,
  
  collapse="|"
  
)

if(nrow(offres) > 0){
  
  
  offres <- offres %>%
    
    filter(
      
      !str_detect(
        
        str_to_lower(lien),
        
        pattern_exclusion
        
      )
      
    )
  
  
}

print(
  paste(
    "Après suppression pages inutiles :",
    nrow(offres)
  )
)

# ==========================================
# FILTRAGE CIBLE PAR SOURCE
# ==========================================
# Certaines sources renvoient un mélange de vraies offres
# individuelles ET de pages génériques (navigation, suggestions
# de recherche similaires). On applique une règle précise par
# source pour ne garder que les vraies annonces.

if(nrow(offres) > 0){
  
  
  offres <- offres %>%
    
    filter(
      
      case_when(
        
        # LinkedIn : une vraie offre a toujours "/jobs/view/" dans l'URL.
        # Les liens "trk=public_jobs_similar-title" ou "/jobs/xxx-jobs"
        # sont des pages de catégorie/suggestion, pas des annonces.
        source == "LinkedIn Jobs" ~ str_detect(lien, "/jobs/view/"),
        
        # UNICEF : une vraie offre contient toujours "/job/" suivi
        # d'un identifiant numérique. Les pages "/careers/..." sans
        # identifiant sont des pages de navigation générales.
        source == "UNICEF" ~ str_detect(lien, "/job/[0-9]+"),
        
        # Autres sources : on garde tel quel (déjà validé plus haut)
        TRUE ~ TRUE
        
      )
      
    )
  
  
}

print(
  paste(
    "Après filtrage ciblé par source :",
    nrow(offres)
  )
)

# ==========================================
# NORMALISATION
# ==========================================

if(nrow(offres) > 0){
  
  
  offres <- offres %>%
    
    mutate(
      
      lien = str_trim(lien),
      
      source = str_trim(source),
      
      date_collecte = as.character(date_collecte)
      
    )
  
  
}

# ==========================================
# EXPORT
# ==========================================

dir.create(
  
  "Data",
  
  showWarnings = FALSE
  
)

write.csv(
  
  offres,
  
  "Data/offres_filtrees.csv",
  
  row.names = FALSE,
  
  fileEncoding = "UTF-8"
  
)

print("--------------------------------")

print(
  "Fichier créé : Data/offres_filtrees.csv"
)

print(
  paste(
    "Nombre final offres candidates :",
    nrow(offres)
  )
)

print(
  "JOB HUNTER CI - NETTOYAGE TERMINE"
)