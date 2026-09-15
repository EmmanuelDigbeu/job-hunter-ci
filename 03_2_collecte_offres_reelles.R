# ==========================================
# JOB HUNTER CI
# Script 03_2 : Collecte offres réelles
# VERSION CORRIGEE (encodage UTF-8 + robustesse)
# ==========================================

rm(list = ls())

print("================================")
print("JOB HUNTER CI - COLLECTE OFFRES REELLES")
print("================================")

setwd("~/CV Ange Emmanuel/JOB_HUNTER_CI")

# ==========================================
# LIBRAIRIES
# ==========================================

library(httr)
library(rvest)
library(dplyr)
library(stringr)
library(purrr)

# ==========================================
# CHARGEMENT SOURCES
# ==========================================

source(
  "Scripts/03_configuration_sources_offres.R"
)

print("Sources chargées")

# ==========================================
# DOSSIERS
# ==========================================

dir.create(
  "Data",
  showWarnings = FALSE
)

historique_file <- "Data/historique_offres.csv"

# ==========================================
# HISTORIQUE EXISTANT
# ==========================================

if(file.exists(historique_file) && file.info(historique_file)$size > 0){
  
  
  historique <- tryCatch(
    
    read.csv(
      historique_file,
      stringsAsFactors = FALSE
    ),
    
    error = function(e){
      
      message(
        paste0(
          "Historique illisible, il sera recréé : ",
          e$message
        )
      )
      
      return(data.frame())
      
    }
    
  )
  
  
  print(
    paste(
      "Historique chargé :",
      nrow(historique),
      "offres"
    )
  )
  
  
}else{
  
  
  historique <- data.frame()
  
  
  print(
    "Aucun historique existant"
  )
  
}

# ==========================================
# FONCTION SECURISATION ENCODAGE
# ==========================================
# Corrige les chaines contenant des bytes UTF-8 invalides
# (typiquement rencontré sur les pages Google Jobs / redirections)

securiser_encodage <- function(x){
  
  if(is.null(x) || length(x) == 0){
    return(x)
  }
  
  x <- iconv(x, from = "UTF-8", to = "UTF-8", sub = "")
  
  return(x)
  
}

# ==========================================
# FONCTION NETTOYAGE
# ==========================================

nettoyer <- function(x){
  
  
  if(length(x)==0 || is.null(x)){
    return(NA)
  }
  
  
  # Sécurisation encodage AVANT tout traitement regex
  x <- securiser_encodage(x)
  
  
  if(is.na(x)){
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
# EXTRACTION EMAIL
# ==========================================

extraire_email <- function(texte){
  
  
  email <- str_extract(
    texte,
    "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
  )
  
  
  return(email)
  
}

# ==========================================
# TYPE CONTRAT
# ==========================================

detecter_contrat <- function(texte){
  
  
  texte <- str_to_lower(texte)
  
  
  if(str_detect(texte,"cdi|permanent")){
    
    return("CDI")
    
  }
  
  
  if(str_detect(texte,"cdd|temporary|fixed term")){
    
    return("CDD")
    
  }
  
  
  if(str_detect(texte,"stage|internship|intern")){
    
    return("Stage")
    
  }
  
  
  if(str_detect(texte,"consultant|consultancy")){
    
    return("Consultant")
    
  }
  
  
  if(str_detect(texte,"freelance")){
    
    return("Freelance")
    
  }
  
  
  return(NA)
  
}

# ==========================================
# EXTRACTION UNE PAGE
# ==========================================

extraire_offre <- function(url, source){
  
  
  resultat <- data.frame()
  
  
  page <- tryCatch(
    
    {
      
      reponse <- GET(
        
        url,
        
        timeout(20),
        
        user_agent(
          "JOB HUNTER CI - Data Analyst Agent"
        ),
        
        # NOTE : la vérification stricte du certificat SSL est désactivée
        # car un logiciel (antivirus / filtre réseau) intercepte le HTTPS
        # sur cette machine et curl ne reconnaît pas son certificat.
        # Sans risque ici car on scrape uniquement des pages PUBLIQUES
        # (aucune donnée personnelle/sensible n'est envoyée).
        config(ssl_verifypeer = FALSE)
        
      )
      
      
      contenu_brut <- content(
        reponse,
        as = "text",
        encoding = "UTF-8"
      )
      
      
      # Vérification : contenu manquant ou vide (page bloquée,
      # redirection, réponse vide) -> on arrête proprement ici
      if(is.na(contenu_brut) || nchar(contenu_brut) == 0){
        
        stop("Contenu vide ou non exploitable reçu du serveur")
        
      }
      
      
      contenu_brut <- securiser_encodage(contenu_brut)
      
      
      # IMPORTANT : on convertit en raw avant de parser.
      # xml2::read_html() interprète parfois les chaines courtes
      # (ex : messages d'erreur JSON courts renvoyés par certains sites)
      # comme un CHEMIN DE FICHIER plutot que comme du contenu HTML brut,
      # ce qui provoque une erreur "n'existe pas dans le répertoire".
      # Passer par raw contourne ce piège.
      read_html(
        charToRaw(contenu_brut)
      )
      
      
    },
    
    error=function(e){
      
      message(
        paste0(
          "Erreur lecture HTML pour la source '",
          source,
          "' : ",
          e$message
        )
      )
      
      return(NULL)
      
    }
    
  )
  
  
  if(is.null(page)){
    return(NULL)
  }
  
  
  # ==========================================
  # TOUT LE TRAITEMENT APRES LECTURE HTML
  # EST PROTEGE PAR tryCatch
  # (empeche un souci d'encodage ou de structure
  # sur UNE source d'arreter tout le pipeline)
  # ==========================================
  
  ligne <- tryCatch({
    
    
    texte <- page %>%
      html_text2()
    
    
    # Sécurisation immédiate de l'encodage du texte brut
    texte <- securiser_encodage(texte)
    
    
    if(is.na(texte) || length(texte) == 0){
      texte <- ""
    }
    
    
    
    titre <- page %>%
      html_element("title") %>%
      html_text()
    
    
    titre <- securiser_encodage(titre)
    
    
    
    ligne_resultat <- data.frame(
      
      
      date_collecte = as.character(Sys.Date()),
      
      
      poste = nettoyer(titre),
      
      
      entreprise = NA,
      
      
      localisation = str_extract(
        texte,
        "(?i)(Abidjan|Côte d'Ivoire|Remote|Africa)"
      ),
      
      
      type_contrat = detecter_contrat(
        texte
      ),
      
      
      email_candidature = extraire_email(
        texte
      ),
      
      
      description = nettoyer(
        substr(
          texte,
          1,
          2000
        )
      ),
      
      
      lien_offre = url,
      
      
      source = source,
      
      
      stringsAsFactors = FALSE
      
      
    )
    
    
    return(ligne_resultat)
    
    
  }, error = function(e){
    
    
    message(
      paste0(
        "Erreur traitement texte pour la source '",
        source,
        "' : ",
        e$message
      )
    )
    
    
    return(NULL)
    
    
  })
  
  
  return(ligne)
  
}

# ==========================================
# COLLECTE
# ==========================================

nouvelles_offres <- data.frame()

for(i in seq_len(nrow(sources))){
  
  
  
  if(
    sources$actif[i] == FALSE
  ){
    
    next
    
  }
  
  
  
  print("--------------------------------")
  
  
  print(
    paste(
      "Source :",
      sources$nom_source[i]
    )
  )
  
  
  
  
  resultat <- extraire_offre(
    
    sources$url_recherche[i],
    
    sources$nom_source[i]
    
  )
  
  
  
  
  if(!is.null(resultat)){
    
    
    nouvelles_offres <- bind_rows(
      
      nouvelles_offres,
      
      resultat
      
    )
    
    
  }else{
    
    
    print(
      paste(
        "Source ignorée (erreur) :",
        sources$nom_source[i]
      )
    )
    
    
  }
  
  
}

# ==========================================
# SUPPRESSION DOUBLONS
# ==========================================

if(nrow(nouvelles_offres) > 0 && "lien_offre" %in% names(nouvelles_offres)){
  
  
  nouvelles_offres <- nouvelles_offres %>%
    
    
    distinct(
      lien_offre,
      .keep_all = TRUE
    )
  
  
}else{
  
  
  print("Aucune offre collectée sur cette exécution")
  
  
}

# ==========================================
# COMPARAISON HISTORIQUE
# ==========================================

if(nrow(historique)>0 && nrow(nouvelles_offres) > 0){
  
  
  nouvelles_offres <- nouvelles_offres %>%
    
    filter(
      
      !lien_offre %in% historique$lien_offre
      
    )
  
  
}

# ==========================================
# SAUVEGARDE
# ==========================================

write.csv(
  
  nouvelles_offres,
  
  "Data/offres_brutes.csv",
  
  row.names = FALSE,
  
  fileEncoding = "UTF-8"
  
)

historique_final <- bind_rows(
  
  historique,
  
  nouvelles_offres
  
)

write.csv(
  
  historique_final,
  
  historique_file,
  
  row.names = FALSE,
  
  fileEncoding = "UTF-8"
  
)

print("--------------------------------")

print(
  paste(
    "Nouvelles offres trouvées :",
    nrow(nouvelles_offres)
  )
)

print(
  "Fichier créé : Data/offres_brutes.csv"
)

print(
  "JOB HUNTER CI - COLLECTE REELLE TERMINEE"
)