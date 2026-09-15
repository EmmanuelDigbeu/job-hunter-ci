# ==========================================
# JOB HUNTER CI
# 04_3 - COLLECTE DETAILS OFFRES V5
# ==========================================

rm(list = ls())

print("================================")
print("JOB HUNTER CI - DETAILS OFFRES V5")
print("================================")


library(rvest)
library(dplyr)
library(stringr)
library(jsonlite)


# ==========================================
# FICHIERS
# ==========================================

fichier_entree <- "Data/offres_filtrees.csv"
fichier_sortie <- "Data/offres_details.csv"


offres <- read.csv(
  fichier_entree,
  stringsAsFactors = FALSE
)


print(
  paste(
    "Nombre offres à analyser :",
    nrow(offres)
  )
)



# ==========================================
# FONCTION NETTOYAGE TEXTE
# ==========================================

nettoyer <- function(x){
  
  if(length(x)==0 || is.null(x)){
    return(NA)
  }
  
  x <- x %>%
    str_replace_all("\\s+"," ") %>%
    str_trim()
  
  if(x==""){
    return(NA)
  }
  
  return(x)
}



# ==========================================
# EXTRACTION DETAILS
# ==========================================

extraire_offre <- function(url){
  
  
  resultat <- list()
  
  
  page <- tryCatch(
    
    read_html(url),
    
    error=function(e){
      return(NULL)
    }
    
  )
  
  
  if(is.null(page)){
    return(resultat)
  }
  
  
  
  texte <- page %>%
    html_text2()
  
  
  
  titre <- page %>%
    html_element("title") %>%
    html_text()
  
  
  
  # POSTE
  
  resultat$poste <- nettoyer(titre)
  
  
  
  # ENTREPRISE
  
  if(str_detect(
    str_to_lower(texte),
    "unicef"
  )){
    
    resultat$entreprise <- "UNICEF"
    
  } else {
    
    resultat$entreprise <- NA
    
  }
  
  
  
  # LOCALISATION
  
  localisation <- str_extract(
    texte,
    "(?i)(location|duty station|based in)[: ]{0,5}.{0,80}"
  )
  
  
  resultat$localisation <- nettoyer(localisation)
  
  
  
  # DESCRIPTION
  
  resultat$description <- nettoyer(
    substr(
      texte,
      1,
      3000
    )
  )
  
  
  
  return(resultat)
  
}




# ==========================================
# BOUCLE
# ==========================================

details <- data.frame()



for(i in seq_len(nrow(offres))){
  
  
  url <- offres$lien[i]
  
  
  print("--------------------------------")
  
  print(
    paste(
      "Analyse",
      i,
      "/",
      nrow(offres),
      ":",
      url
    )
  )
  
  
  
  tryCatch({
    
    
    data <- extraire_offre(url)
    
    
    
    ligne <- data.frame(
      
      date_collecte = Sys.Date(),
      
      poste = ifelse(
        is.null(data$poste),
        NA,
        data$poste
      ),
      
      entreprise = ifelse(
        is.null(data$entreprise),
        NA,
        data$entreprise
      ),
      
      localisation = ifelse(
        is.null(data$localisation),
        NA,
        data$localisation
      ),
      
      description = ifelse(
        is.null(data$description),
        NA,
        data$description
      ),
      
      competences = NA,
      
      contrat = NA,
      
      experience = NA,
      
      niveau = NA,
      
      lien = url,
      
      source = offres$source[i],
      
      stringsAsFactors = FALSE
    )
    
    
    
    details <- bind_rows(
      details,
      ligne
    )
    
    
    print("Extraction OK")
    
    
  },
  
  error=function(e){
    
    print(
      paste(
        "Erreur :",
        e$message
      )
    )
    
  })
  
  
}



# ==========================================
# EXPORT
# ==========================================


write.csv(
  details,
  fichier_sortie,
  row.names = FALSE
)



print("--------------------------------")

print(
  paste(
    "Nombre offres détaillées :",
    nrow(details)
  )
)


print(
  "Fichier créé : Data/offres_details.csv"
)


print(
  "JOB HUNTER CI - DETAILS V5 TERMINE"
)