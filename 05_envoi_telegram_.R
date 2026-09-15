# ==========================================
# JOB HUNTER CI
# Script 05 : Envoi des offres par Telegram
# ==========================================

rm(list = ls())

print("================================")
print("JOB HUNTER CI - ENVOI TELEGRAM")
print("================================")

setwd("~/CV Ange Emmanuel/JOB_HUNTER_CI")

library(httr)
library(dplyr)

# ==========================================
# IDENTIFIANTS TELEGRAM
# ==========================================
# IMPORTANT : remplace ces deux valeurs par les tiennes.
# Ne partage jamais ce fichier une fois rempli (le token donne
# un accès complet à ton bot).

mon_token   <- "xxxxxxxxxxxxxxxx"
mon_chat_id <- "xxxxxxxxxxxxxxxxxx"

# ==========================================
# CHARGEMENT DES OFFRES SCOREES
# ==========================================

fichier_entree <- "Data/offres_scorees.csv"

if(!file.exists(fichier_entree)){
  
  stop(
    "Fichier Data/offres_scorees.csv introuvable. Lance d'abord le script 04."
  )
  
}

offres <- read.csv(
  fichier_entree,
  stringsAsFactors = FALSE
)

print(
  paste(
    "Nombre offres chargées :",
    nrow(offres)
  )
)

# ==========================================
# SELECTION DES OFFRES A ENVOYER
# ==========================================
# On envoie toutes les offres avec un score >= 40, triées par
# score décroissant, limitées à 15.
# NOTE : le seuil a été remonté de 30 à 40 le 24/07/2026 car un
# bruit uniforme à 35 (pollution du texte de navigation/sidebar
# des pages JobIvoire) faisait remonter des offres hors-sujet
# (chauffeur, charpentier, infographe...). 40 exclut ce bruit
# tout en gardant les vraies offres pertinentes.

SEUIL_ENVOI <- 40
NB_MAX_OFFRES <- 15

offres_a_envoyer <- offres %>%
  
  filter(score_final >= SEUIL_ENVOI) %>%
  
  arrange(desc(score_final)) %>%
  
  head(NB_MAX_OFFRES)

print(
  paste(
    "Offres sélectionnées pour envoi (score >=",
    SEUIL_ENVOI,
    ") :",
    nrow(offres_a_envoyer)
  )
)

# ==========================================
# FONCTION ENVOI D'UN MESSAGE TELEGRAM
# ==========================================

envoyer_message_telegram <- function(texte){
  
  
  resultat <- tryCatch({
    
    
    reponse <- POST(
      
      url = paste0(
        "https://api.telegram.org/bot",
        mon_token,
        "/sendMessage"
      ),
      
      config(ssl_verifypeer = FALSE),
      
      body = list(
        chat_id = mon_chat_id,
        text = texte,
        parse_mode = "HTML",
        disable_web_page_preview = TRUE
      ),
      
      encode = "form"
      
    )
    
    
    if(status_code(reponse) == 200){
      
      return(TRUE)
      
    }else{
      
      message(
        paste(
          "Erreur envoi Telegram, code :",
          status_code(reponse)
        )
      )
      
      return(FALSE)
      
    }
    
    
  }, error = function(e){
    
    
    message(
      paste(
        "Erreur envoi Telegram :",
        e$message
      )
    )
    
    return(FALSE)
    
  })
  
  
  return(resultat)
  
}

# ==========================================
# FONCTION NETTOYAGE HTML TELEGRAM
# ==========================================
# Telegram interprète certains caractères en HTML (<, >, &).
# On les échappe pour éviter que le message soit rejeté ou mal
# affiché si un titre d'offre contient ces caractères.

echapper_html <- function(x){
  
  if(is.na(x)){
    return("")
  }
  
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  
  return(x)
  
}

# ==========================================
# CONSTRUCTION ET ENVOI DU MESSAGE RECAPITULATIF
# ==========================================

if(nrow(offres_a_envoyer) == 0){
  
  
  message_intro <- paste0(
    "🔍 <b>JOB HUNTER CI</b>\n",
    "Date : ", Sys.Date(), "\n\n",
    "Aucune offre pertinente trouvée aujourd'hui (score >= ",
    SEUIL_ENVOI,
    ")."
  )
  
  envoyer_message_telegram(message_intro)
  
  print("Aucune offre à envoyer - message d'information envoyé")
  
}else{
  
  
  # ----- Message d'introduction -----
  
  message_intro <- paste0(
    "🔍 <b>JOB HUNTER CI</b>\n",
    "Date : ", Sys.Date(), "\n",
    nrow(offres_a_envoyer), " offre(s) trouvée(s) aujourd'hui\n",
    "━━━━━━━━━━━━━━━━━━━━"
  )
  
  envoyer_message_telegram(message_intro)
  
  Sys.sleep(0.5)
  
  
  # ----- Un message par offre -----
  
  for(i in seq_len(nrow(offres_a_envoyer))){
    
    
    offre <- offres_a_envoyer[i, ]
    
    
    # Emoji selon la catégorie, pour repérage visuel rapide
    emoji_categorie <- case_when(
      offre$categorie == "Excellent" ~ "🟢",
      offre$categorie == "Bon"       ~ "🔵",
      offre$categorie == "Moyen"     ~ "🟡",
      TRUE ~ "⚪"
    )
    
    
    texte_message <- paste0(
      
      emoji_categorie, " <b>", echapper_html(offre$poste), "</b>\n",
      "📍 ", echapper_html(offre$localisation), "\n",
      "🏢 Source : ", echapper_html(offre$source), "\n",
      "📄 Contrat : ", echapper_html(offre$type_contrat), "\n",
      "⭐ Score : ", offre$score_final, "/100 (", offre$categorie, ")\n",
      "🔗 ", offre$lien_offre
      
    )
    
    
    envoi_ok <- envoyer_message_telegram(texte_message)
    
    
    if(envoi_ok){
      
      print(
        paste0(
          "[", i, "/", nrow(offres_a_envoyer), "] Envoyé : ",
          substr(offre$poste, 1, 50)
        )
      )
      
    }else{
      
      print(
        paste0(
          "[", i, "/", nrow(offres_a_envoyer), "] ECHEC : ",
          substr(offre$poste, 1, 50)
        )
      )
      
    }
    
    
    # Petite pause pour respecter les limites Telegram
    # (max ~30 messages/seconde, on reste large)
    Sys.sleep(0.7)
    
    
  }
  
  
}

print("--------------------------------")
print("JOB HUNTER CI - ENVOI TELEGRAM TERMINE")