# ==========================================
# JOB HUNTER CI
# Script 04 : Extraction détails + Scoring des offres
# ==========================================

rm(list = ls())

print("================================")
print("JOB HUNTER CI - EXTRACTION + SCORING")
print("================================")

setwd("~/CV Ange Emmanuel/JOB_HUNTER_CI")

# ==========================================
# LIBRAIRIES
# ==========================================

library(httr)
library(rvest)
library(dplyr)
library(stringr)

# ==========================================
# CHARGEMENT DES OFFRES FILTREES
# ==========================================

fichier_entree <- "Data/offres_filtrees.csv"

if(!file.exists(fichier_entree)){
  
  stop(
    "Fichier Data/offres_filtrees.csv introuvable. Lance d'abord 03_2_1 puis 03_2_2."
  )
  
}

offres <- read.csv(
  fichier_entree,
  stringsAsFactors = FALSE
)

print(
  paste(
    "Nombre offres à traiter :",
    nrow(offres)
  )
)

# ==========================================
# PROFIL CANDIDAT - MOTS CLES PONDERES
# ==========================================
# Chaque mot clé a un poids selon son importance pour ton profil.
# Tu peux ajuster librement ces poids ou en ajouter/retirer.
# Plus le poids est haut, plus le mot clé compte dans le score final.

mots_cles_competences <- c(
  
  # ----- Métiers / intitulés de poste -----
  "data analyst"        = 10,
  "data analyste"       = 10,
  "analyste de données" = 10,
  "business analyst"    = 9,
  "bi analyst"          = 9,
  "business intelligence analyst" = 9,
  "reporting analyst"   = 8,
  "data reporting"      = 7,
  "junior data analyst" = 8,
  "analyste financier"  = 5,
  "analyste statistique" = 6,
  
  # ----- Outils de Business Intelligence / visualisation -----
  "power bi"            = 10,
  "powerbi"             = 10,
  "dax"                 = 8,
  "power query"         = 8,
  "power pivot"         = 7,
  "tableau software"    = 8,
  "tableau"             = 7,
  "qlik"                = 7,
  "qlikview"            = 7,
  "qliksense"           = 7,
  "looker studio"       = 6,
  "google data studio"  = 6,
  "data visualization"  = 7,
  "visualisation de données" = 7,
  "dashboard"           = 7,
  "tableau de bord"     = 7,
  "graphique"           = 5,
  "graphiques"          = 5,
  "reporting"           = 7,
  
  # ----- Excel -----
  "excel"               = 8,
  "excel avancé"        = 9,
  "tableaux croisés dynamiques" = 7,
  "tcd"                 = 6,
  "vba"                 = 7,
  "macro excel"         = 6,
  "macros"              = 5,
  "formules excel"      = 5,
  
  # ----- Langages & programmation -----
  "sql"                 = 9,
  "python"              = 8,
  "pandas"              = 6,
  "numpy"               = 5,
  "r studio"            = 6,
  "langage r"           = 6,
  "vba access"          = 4,
  
  # ----- Bases de données -----
  "base de données"     = 6,
  "database"            = 6,
  "data warehouse"      = 6,
  "etl"                 = 6,
  "sql server"          = 6,
  "mysql"               = 5,
  "postgresql"          = 5,
  "access"              = 4,
  
  # ----- Data / Analyse -----
  "data engineer"       = 6,
  "data scientist"      = 6,
  "data cleaning"       = 6,
  "nettoyage de données" = 6,
  "data mining"         = 5,
  "kpi"                 = 6,
  "indicateurs de performance" = 6,
  "statistiques"        = 6,
  "analyse statistique" = 6,
  "prévisions"          = 5,
  "forecasting"         = 5,
  "modélisation de données" = 5,
  "data governance"     = 4,
  "qualité de données"  = 5,
  
  # ----- Outils connexes souvent demandés -----
  "sap"                 = 4,
  "erp"                 = 4,
  "crm"                 = 4,
  "salesforce"          = 4,
  "google analytics"    = 5,
  "spss"                = 5,
  "sas"                 = 5,
  "sharepoint"          = 3
  
)

# ==========================================
# MOTS CLES DISTINCTIFS (sous-ensemble)
# ==========================================
# Ces mots-clés sont propres au métier de data analyst et ne se
# retrouvent quasiment jamais dans une offre d'un autre métier
# (contrôle de gestion, commercial, RH...). On les distingue des
# mots-clés "génériques" ci-dessus (excel, reporting, kpi...) qui
# apparaissent aussi très souvent dans des offres non-data
# (ex : un contrôleur de gestion utilise Excel/KPI/reporting sans
# être un data analyst). Un score élevé nécessite au moins un de
# ces mots-clés distinctifs, sinon il est plafonné plus bas.

mots_cles_distinctifs <- c(
  "data analyst",
  "data analyste",
  "analyste de données",
  "business analyst",
  "bi analyst",
  "business intelligence analyst",
  "data reporting",
  "junior data analyst",
  "power bi",
  "powerbi",
  "dax",
  "power query",
  "tableau software",
  "qlik",
  "qlikview",
  "qliksense",
  "sql",
  "python",
  "pandas",
  "data engineer",
  "data scientist",
  "data warehouse",
  "etl",
  "data mining",
  "data visualization",
  "visualisation de données"
)

# ==========================================
# MOTS CLES LOCALISATION
# ==========================================
# Bonus si l'offre mentionne une localisation pertinente pour toi.

mots_cles_localisation <- c(
  
  "abidjan"          = 20,
  "côte d'ivoire"    = 20,
  "cote d'ivoire"    = 20,
  "ivory coast"      = 18,
  "afrique de l'ouest" = 12,
  "west africa"      = 12,
  "afrique"          = 8,
  "africa"           = 8,
  "remote"           = 10,
  "télétravail"      = 10,
  "hybrid"           = 6
  
)

# ==========================================
# MOTS CLES EXCLUSION
# ==========================================
# Si présents, pénalisent fortement le score (offre peu pertinente
# ou conditions non désirées). Ajuste selon tes préférences.

mots_cles_exclusion <- c(
  
  "bénévole"           = 15,
  "unpaid"             = 15,
  "non rémunéré"       = 15,
  "stage non rémunéré" = 20,
  "senior director"    = 8,
  "10 years"           = 6,
  "15 years"           = 8
  
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
# FONCTION DETECTION MOT ENTIER
# ==========================================
# IMPORTANT : évite les faux positifs de sous-chaîne. Sans cette
# précaution, un mot-clé court comme "access" se déclenchait aussi
# à l'intérieur du mot "accessible", "sap" à l'intérieur d'un autre
# mot, etc. On force une correspondance en tant que mot complet
# (bordé par des limites de mot \\b).

contient_mot <- function(texte, mot){
  
  if(is.na(texte) || is.na(mot)){
    return(FALSE)
  }
  
  motif <- paste0("\\b", str_to_lower(mot), "\\b")
  
  return(
    str_detect(
      str_to_lower(texte),
      regex(motif)
    )
  )
  
}

# ==========================================
# FONCTION NETTOYAGE TEXTE
# ==========================================

nettoyer <- function(x){
  
  if(length(x) == 0 || is.null(x)){
    return(NA)
  }
  
  x <- securiser_encodage(x)
  
  if(is.na(x)){
    return(NA)
  }
  
  x <- x %>%
    str_replace_all("\\s+", " ") %>%
    str_trim()
  
  if(x == ""){
    return(NA)
  }
  
  return(x)
  
}

# ==========================================
# FONCTION DETECTION TYPE CONTRAT
# ==========================================

detecter_contrat <- function(texte){
  
  
  if(is.na(texte)){
    return(NA)
  }
  
  
  texte <- str_to_lower(texte)
  
  
  if(str_detect(texte, "cdi|permanent")){
    return("CDI")
  }
  
  if(str_detect(texte, "cdd|temporary|fixed term|fixed-term")){
    return("CDD")
  }
  
  if(str_detect(texte, "stage|internship|intern\\b")){
    return("Stage")
  }
  
  if(str_detect(texte, "consultant|consultancy")){
    return("Consultant")
  }
  
  if(str_detect(texte, "freelance")){
    return("Freelance")
  }
  
  if(str_detect(texte, "volontaire|volunteer|unv")){
    return("Volontariat")
  }
  
  return(NA)
  
}

# ==========================================
# FONCTION EXTRACTION LOCALISATION
# ==========================================

extraire_localisation <- function(texte){
  
  
  if(is.na(texte)){
    return(NA)
  }
  
  
  loc <- str_extract(
    texte,
    "(?i)(Abidjan|Côte d'Ivoire|Cote d'Ivoire|Ivory Coast|Dakar|S[ée]n[ée]gal|Accra|Ghana|Lagos|Nigeria|Bamako|Mali|Freetown|Sierra Leone|West Africa|Afrique de l'Ouest|Remote|Télétravail|Africa|Afrique)"
  )
  
  
  return(loc)
  
}

# ==========================================
# FONCTION EXTRACTION D'UNE OFFRE
# ==========================================

extraire_details <- function(url){
  
  
  resultat <- tryCatch({
    
    
    reponse <- GET(
      
      url,
      
      timeout(15),
      
      user_agent(
        "JOB HUNTER CI - Data Analyst Agent"
      ),
      
      # Verification SSL desactivee (voir explication scripts precedents)
      config(ssl_verifypeer = FALSE)
      
    )
    
    
    contenu_brut <- content(
      reponse,
      as = "text",
      encoding = "UTF-8"
    )
    
    
    if(is.na(contenu_brut) || nchar(contenu_brut) == 0){
      
      stop("Contenu vide")
      
    }
    
    
    contenu_brut <- securiser_encodage(contenu_brut)
    
    
    page <- read_html(
      charToRaw(contenu_brut)
    )
    
    
    titre_brut <- page %>%
      html_element("title") %>%
      html_text()
    
    
    # Sur les sites en JavaScript (ex : PNUD/Oracle Cloud), la balise
    # <title> reste générique ("UNDP"). Le vrai titre du poste est
    # souvent présent dans la balise meta "og:title" (utilisée pour
    # le partage sur les réseaux sociaux, générée côté serveur).
    og_titre <- page %>%
      html_element("meta[property='og:title']") %>%
      html_attr("content")
    
    
    titre <- if(
      !is.na(og_titre) &&
      nchar(str_trim(og_titre)) > 3
    ){
      og_titre
    }else{
      titre_brut
    }
    
    
    titre <- nettoyer(titre)
    
    
    og_description <- page %>%
      html_element("meta[property='og:description']") %>%
      html_attr("content")
    
    
    og_description <- nettoyer(og_description)
    
    
    texte <- page %>%
      html_text2()
    
    
    texte <- securiser_encodage(texte)
    
    
    if(is.na(texte)){
      texte <- ""
    }
    
    
    # On ajoute la meta description en tête du texte : sur les pages
    # JS elle contient souvent plus d'information utile que le corps
    # de page (qui peut être vide côté HTML brut).
    if(!is.na(og_description)){
      
      texte <- paste(og_description, texte)
      
    }
    
    
    # On garde un extrait suffisant pour le scoring sans surcharger
    extrait <- substr(texte, 1, 4000)
    
    
    type_contrat <- detecter_contrat(extrait)
    
    
    localisation <- extraire_localisation(extrait)
    
    
    list(
      titre = titre,
      texte = extrait,
      type_contrat = type_contrat,
      localisation = localisation,
      statut_extraction = "OK"
    )
    
    
  }, error = function(e){
    
    
    list(
      titre = NA,
      texte = NA,
      type_contrat = NA,
      localisation = NA,
      statut_extraction = paste(
        "Erreur :",
        e$message
      )
    )
    
    
  })
  
  
  return(resultat)
  
}

# ==========================================
# FONCTION CALCUL SCORE
# ==========================================

calculer_score <- function(titre, texte){
  
  
  # Si aucun contenu exploitable, score nul
  if(is.na(titre) && is.na(texte)){
    
    return(
      list(
        score_competences = 0,
        score_localisation = 0,
        penalite_exclusion = 0,
        a_mot_distinctif = FALSE,
        score_final = 0
      )
    )
    
  }
  
  
  # Contenu combiné (titre + texte) pour la recherche de mots clés
  contenu_complet <- paste(
    ifelse(is.na(titre), "", titre),
    ifelse(is.na(texte), "", texte)
  )
  
  
  contenu_complet <- str_to_lower(contenu_complet)
  
  
  
  # ----- Score compétences -----
  
  score_competences <- 0
  
  for(mot in names(mots_cles_competences)){
    
    if(contient_mot(contenu_complet, mot)){
      
      score_competences <- score_competences + mots_cles_competences[[mot]]
      
    }
    
  }
  
  
  
  # ----- Vérification présence d'un mot-clé distinctif -----
  # Sans mot-clé distinctif, l'offre n'est probablement pas un
  # vrai poste data analyst (juste un métier qui partage quelques
  # mots génériques comme "excel" ou "reporting").
  
  a_mot_distinctif <- FALSE
  
  for(mot in mots_cles_distinctifs){
    
    if(contient_mot(contenu_complet, mot)){
      
      a_mot_distinctif <- TRUE
      break
      
    }
    
  }
  
  
  
  # ----- Bonus titre -----
  # Bonus supplémentaire si un mot-clé distinctif apparaît dans
  # le TITRE du poste lui-même (signal beaucoup plus fiable
  # qu'une simple mention dans le corps du texte).
  
  bonus_titre <- 0
  
  if(!is.na(titre)){
    
    for(mot in mots_cles_distinctifs){
      
      if(contient_mot(titre, mot)){
        
        bonus_titre <- 15
        break
        
      }
      
    }
    
  }
  
  
  
  score_competences <- score_competences + bonus_titre
  
  
  
  # ----- Score localisation -----
  
  score_localisation <- 0
  
  for(mot in names(mots_cles_localisation)){
    
    if(contient_mot(contenu_complet, mot)){
      
      score_localisation <- score_localisation + mots_cles_localisation[[mot]]
      
    }
    
  }
  
  
  
  # ----- Pénalité exclusion -----
  
  penalite_exclusion <- 0
  
  for(mot in names(mots_cles_exclusion)){
    
    if(contient_mot(contenu_complet, mot)){
      
      penalite_exclusion <- penalite_exclusion + mots_cles_exclusion[[mot]]
      
    }
    
  }
  
  
  
  # ----- Score final -----
  # Somme compétences + localisation, moins pénalités,
  # plafonné entre 0 et 100.
  
  score_brut <- score_competences + score_localisation - penalite_exclusion
  
  score_final <- max(0, min(100, score_brut))
  
  
  
  # ----- Plafonnement si aucun mot-clé distinctif -----
  # Sans mot-clé distinctif, on considère que l'offre n'est
  # probablement pas un vrai poste data analyst, même si le score
  # brut est élevé (accumulation de mots génériques comme
  # excel/reporting/kpi présents dans beaucoup d'autres métiers).
  # On plafonne alors à 35 (jamais "Bon" ni "Excellent").
  
  if(!a_mot_distinctif){
    
    score_final <- min(score_final, 35)
    
  }
  
  
  
  return(
    list(
      score_competences = score_competences,
      score_localisation = score_localisation,
      penalite_exclusion = penalite_exclusion,
      a_mot_distinctif = a_mot_distinctif,
      score_final = score_final
    )
  )
  
}

# ==========================================
# BOUCLE PRINCIPALE : EXTRACTION + SCORING
# ==========================================

resultats_finaux <- data.frame()

nb_total <- nrow(offres)

for(i in seq_len(nb_total)){
  
  
  if(i %% 10 == 0 || i == 1){
    
    print(
      paste0(
        "Traitement offre ",
        i,
        " / ",
        nb_total
      )
    )
    
  }
  
  
  
  details <- extraire_details(
    offres$lien[i]
  )
  
  
  
  score <- calculer_score(
    details$titre,
    details$texte
  )
  
  
  
  ligne <- data.frame(
    
    date_analyse = as.character(Sys.Date()),
    
    source = offres$source[i],
    
    poste = ifelse(
      is.na(details$titre),
      "Titre non extrait",
      details$titre
    ),
    
    localisation = ifelse(
      is.na(details$localisation),
      "Non précisée",
      details$localisation
    ),
    
    type_contrat = ifelse(
      is.na(details$type_contrat),
      "Non précisé",
      details$type_contrat
    ),
    
    score_final = score$score_final,
    
    score_competences = score$score_competences,
    
    score_localisation = score$score_localisation,
    
    penalite_exclusion = score$penalite_exclusion,
    
    lien_offre = offres$lien[i],
    
    statut_extraction = details$statut_extraction,
    
    stringsAsFactors = FALSE
    
  )
  
  
  
  resultats_finaux <- bind_rows(
    
    resultats_finaux,
    
    ligne
    
  )
  
  
  
  # Petite pause pour ne pas surcharger les serveurs
  # (100 requêtes d'affilée sans pause peut déclencher des blocages)
  Sys.sleep(0.3)
  
  
}

# ==========================================
# CATEGORISATION
# ==========================================

resultats_finaux <- resultats_finaux %>%
  
  mutate(
    
    categorie = case_when(
      
      score_final >= 70 ~ "Excellent",
      
      score_final >= 50 ~ "Bon",
      
      score_final >= 30 ~ "Moyen",
      
      TRUE ~ "Faible"
      
    )
    
  )

# ==========================================
# TRI PAR SCORE DECROISSANT
# ==========================================

resultats_finaux <- resultats_finaux %>%
  
  arrange(
    desc(score_final)
  )

# ==========================================
# EXPORT
# ==========================================

dir.create(
  "Data",
  showWarnings = FALSE
)

write.csv(
  
  resultats_finaux,
  
  "Data/offres_scorees.csv",
  
  row.names = FALSE,
  
  fileEncoding = "UTF-8"
  
)

# ==========================================
# SYNTHESE
# ==========================================

print("--------------------------------")

print(
  paste(
    "Extraction et scoring terminés pour",
    nrow(resultats_finaux),
    "offres"
  )
)

print("--------------------------------")

print("Répartition par catégorie :")

print(
  table(resultats_finaux$categorie)
)

print("--------------------------------")

print("TOP 10 des offres les mieux notées :")

print(
  
  resultats_finaux %>%
    
    select(
      source,
      poste,
      localisation,
      score_final,
      categorie,
      lien_offre
    ) %>%
    
    head(10)
  
)

print("--------------------------------")

print(
  "Fichier créé : Data/offres_scorees.csv"
)

print(
  "JOB HUNTER CI - EXTRACTION + SCORING TERMINE"
)