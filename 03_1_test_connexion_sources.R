# ==========================================
# JOB HUNTER CI
# Script 03_1 : Test connexion sources
# VERSION CORRIGEE (contournement blocage SSL local)
# ==========================================

rm(list = ls())

print("================================")
print("JOB HUNTER CI - TEST CONNEXION SOURCES")
print("================================")

# ==========================================
# DOSSIER PROJET
# ==========================================

setwd("~/CV Ange Emmanuel/JOB_HUNTER_CI")

# ==========================================
# CHARGEMENT CONFIGURATION SOURCES
# ==========================================

source(
  "Scripts/03_configuration_sources_offres.R"
)

print("Configuration sources chargée")

# ==========================================
# LIBRAIRIES
# ==========================================

library(httr)
library(dplyr)

# ==========================================
# VERIFICATION STRUCTURE
# ==========================================

print("--------------------------------")
print("Colonnes sources disponibles :")
print(
  names(sources)
)
print("--------------------------------")

# ==========================================
# TABLE RESULTATS
# ==========================================

resultats_sources <- data.frame(
  
  date_test = character(),
  
  source = character(),
  
  url = character(),
  
  statut = character(),
  
  code_http = numeric(),
  
  temps_reponse = numeric(),
  
  stringsAsFactors = FALSE
  
)

# ==========================================
# TEST DES SOURCES
# ==========================================

for(i in seq_len(nrow(sources))){
  
  
  nom_source <- sources$nom_source[i]
  
  
  url_source <- sources$url_recherche[i]
  
  
  
  print("--------------------------------")
  
  print(
    paste(
      "Test source :",
      nom_source
    )
  )
  
  
  print(url_source)
  
  
  
  debut <- Sys.time()
  
  
  
  resultat <- tryCatch(
    
    
    {
      
      
      reponse <- GET(
        
        url_source,
        
        timeout(
          20
        ),
        
        user_agent(
          "JOB HUNTER CI - Data Analyst Agent"
        ),
        
        # NOTE : vérification SSL désactivée - voir explication
        # dans Scripts/03_2_collecte_offres_reelles.R
        config(ssl_verifypeer = FALSE)
        
      )
      
      
      
      fin <- Sys.time()
      
      
      temps <- round(
        as.numeric(
          difftime(
            fin,
            debut,
            units="secs"
          )
        ),
        2
      )
      
      
      
      if(
        status_code(reponse) >= 200 &&
        status_code(reponse) < 400
      ){
        
        
        statut <- "Accessible"
        
        
      }else{
        
        
        statut <- "Erreur HTTP"
        
        
      }
      
      
      
      data.frame(
        
        date_test = as.character(Sys.Date()),
        
        source = nom_source,
        
        url = url_source,
        
        statut = statut,
        
        code_http = status_code(reponse),
        
        temps_reponse = temps,
        
        stringsAsFactors = FALSE
        
      )
      
      
    },
    
    
    error=function(e){
      
      
      message(
        paste0(
          "Erreur connexion pour '",
          nom_source,
          "' : ",
          e$message
        )
      )
      
      
      data.frame(
        
        date_test = as.character(Sys.Date()),
        
        source = nom_source,
        
        url = url_source,
        
        statut = "Erreur connexion",
        
        code_http = NA,
        
        temps_reponse = NA,
        
        stringsAsFactors = FALSE
        
      )
      
      
    }
    
    
  )
  
  
  
  
  resultats_sources <- bind_rows(
    
    resultats_sources,
    
    resultat
    
  )
  
  
  
}

# ==========================================
# SYNTHESE
# ==========================================

print("--------------------------------")
print(
  resultats_sources
)
print("--------------------------------")
print(
  paste(
    "Sources accessibles :",
    sum(
      resultats_sources$statut=="Accessible",
      na.rm = TRUE
    ),
    "/",
    nrow(resultats_sources)
  )
)

# ==========================================
# EXPORT
# ==========================================

dir.create(
  
  "Data",
  
  showWarnings = FALSE
  
)

write.csv(
  
  resultats_sources,
  
  "Data/resultats_test_sources.csv",
  
  row.names = FALSE,
  
  fileEncoding = "UTF-8"
  
)

print("--------------------------------")
print(
  "Fichier créé : Data/resultats_test_sources.csv"
)
print(
  "JOB HUNTER CI - TEST SOURCES TERMINE"
)