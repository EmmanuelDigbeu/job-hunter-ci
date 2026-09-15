# ==========================================
# JOB HUNTER CI
# Script 03_2_1 : Collecte offres multi sources
# VERSION CORRIGEE (SSL + config sources unifiée + robustesse)
# ==========================================

rm(list = ls())

print("================================")
print("JOB HUNTER CI - COLLECTE OFFRES MULTI SOURCES")
print("================================")

setwd("~/CV Ange Emmanuel/JOB_HUNTER_CI")

# ==========================================
# LIBRAIRIES
# ==========================================

library(rvest)
library(dplyr)
library(stringr)
library(httr)

# ==========================================
# SOURCES
# ==========================================
# NOTE : on utilise ici le meme fichier de configuration que le
# reste du pipeline (03_configuration_sources_offres.R), pour que
# toutes les etapes travaillent sur la meme liste de 20 sources.
# Colonnes utilisees : nom_source, url_recherche

source("Scripts/03_configuration_sources_offres.R")

print("Sources chargées")

# ==========================================
# MOTS CLES PROFIL
# ==========================================

mots_cles <- c(
  
  "data analyst",
  "data analyste",
  "business analyst",
  "bi analyst",
  "power bi",
  "sql",
  "python",
  "data engineer",
  "data scientist",
  "reporting"
  
)

pattern <- paste(
  mots_cles,
  collapse="|"
)

# ==========================================
# FONCTION SECURISATION ENCODAGE
# ==========================================

securiser_encodage <- function(x){
  
  if(is.null(x) || length(x) == 0){
    return(x)
  }
  
  x <- iconv(x, from = "UTF-8", to = "UTF-8", sub = "")
  
  return(x)
  
}

# ==========================================
# BASE RESULTAT
# ==========================================

offres <- data.frame(
  
  date_collecte = character(),
  poste = character(),
  entreprise = character(),
  localisation = character(),
  lien = character(),
  source = character(),
  
  stringsAsFactors = FALSE
  
)

# ==========================================
# FONCTION COLLECTE
# ==========================================

collecter_source <- function(url_source, nom_source){
  
  
  resultat <- data.frame()
  
  
  tryCatch({
    
    
    reponse <- GET(
      
      url_source,
      
      timeout(20),
      
      user_agent(
        "JOB HUNTER CI - Data Analyst Agent"
      ),
      
      # NOTE : verification SSL desactivee - voir explication
      # detaillee dans Scripts/03_2_collecte_offres_reelles.R
      config(ssl_verifypeer = FALSE)
      
    )
    
    
    contenu_brut <- content(
      reponse,
      as = "text",
      encoding = "UTF-8"
    )
    
    
    if(is.na(contenu_brut) || nchar(contenu_brut) == 0){
      
      stop("Contenu vide ou non exploitable reçu du serveur")
      
    }
    
    
    contenu_brut <- securiser_encodage(contenu_brut)
    
    
    # Conversion en raw pour eviter que xml2 interprete une chaine
    # courte comme un chemin de fichier plutot que du HTML brut
    page <- read_html(
      charToRaw(contenu_brut)
    )
    
    
    
    liens <- page %>%
      html_elements("a") %>%
      html_attr("href")
    
    
    liens <- liens[
      !is.na(liens)
    ]
    
    
    # IMPORTANT : certains sites (ex : Glassdoor) utilisent des liens
    # relatifs ("/Job/index.htm") qui ne sont pas exploitables tels
    # quels. On les convertit systématiquement en URLs absolues.
    liens <- url_absolute(
      liens,
      url_source
    )
    
    
    liens <- unique(liens)
    
    
    # garder seulement liens ressemblant à des offres
    # CORRIGE : ajout de "offre"/"offres" - très utilisé par les
    # sites d'emploi ivoiriens/francophones (ex: /offre/12345,
    # /offres-emploi/...) et absent du filtre précédent, ce qui
    # bloquait silencieusement Novojob, OptionCarriere, etc.
    
    liens <- liens[
      str_detect(
        str_to_lower(liens),
        "job|emploi|career|offre|offres|vacancy|position|recruit"
      )
    ]
    
    
    if(length(liens)>0){
      
      
      resultat <- data.frame(
        
        date_collecte = as.character(Sys.Date()),
        
        poste = NA,
        
        entreprise = NA,
        
        localisation = NA,
        
        lien = liens,
        
        source = nom_source,
        
        stringsAsFactors = FALSE
        
      )
      
    }else{
      
      
      print(
        paste(
          "Aucun lien offre détecté pour :",
          nom_source
        )
      )
      
      
    }
    
    
    
  },
  
  error=function(e){
    
    
    message(
      paste0(
        "Erreur source '",
        nom_source,
        "' : ",
        e$message
      )
    )
    
    
  })
  
  
  return(resultat)
  
}

# ==========================================
# BOUCLE SOURCES ACTIVES
# ==========================================

for(i in seq_len(nrow(sources))){
  
  
  if(
    sources$actif[i] == FALSE
  ){
    
    next
    
  }
  
  
  
  print("--------------------------------")
  
  print(
    paste(
      "Analyse source :",
      sources$nom_source[i]
    )
  )
  
  
  
  temp <- collecter_source(
    
    sources$url_recherche[i],
    
    sources$nom_source[i]
    
  )
  
  
  
  offres <- bind_rows(
    
    offres,
    temp
    
  )
  
  
}

# ==========================================
# NETTOYAGE SIMPLE
# ==========================================

if(nrow(offres) > 0){
  
  
  offres <- offres %>%
    
    filter(
      !is.na(lien)
    ) %>%
    
    distinct(
      lien,
      .keep_all = TRUE
    )
  
  
}

# ==========================================
# EXPORT
# ==========================================
# NOTE : le fichier de sortie s'appelle "offres_a_analyser.csv"
# car c'est le nom attendu en entrée par le script suivant
# 03_2_2_nettoyage_offres_collectees.R

dir.create(
  "Data",
  showWarnings = FALSE
)

write.csv(
  
  offres,
  
  "Data/offres_a_analyser.csv",
  
  row.names = FALSE,
  
  fileEncoding = "UTF-8"
  
)

print("--------------------------------")

print(
  paste(
    "Nombre offres (liens) trouvées :",
    nrow(offres)
  )
)

print(
  "Fichier créé : Data/offres_a_analyser.csv"
)

print(
  "JOB HUNTER CI - COLLECTE MULTI TERMINE"
)