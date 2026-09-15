# ============================================================
# JOB HUNTER CI
#
# SCRIPT 00
# Lanceur principal du projet
# VERSION CORRIGEE (24/07/2026)
#
# Auteur : Emmanuel DIGBEU
# ============================================================

rm(list = ls())
gc()
cat("\014")

debut <- Sys.time()

print("=====================================================")
print("            JOB HUNTER CI")
print(" Assistant Intelligent de Recherche d'Emploi")
print("=====================================================")

print(
  paste(
    "Date :",
    Sys.Date()
  )
)

print("")

############################################################
# DOSSIER DU PROJET
############################################################

setwd("~/CV Ange Emmanuel/JOB_HUNTER_CI")

############################################################
# CREATION DOSSIERS
############################################################

dir.create("Data",showWarnings = FALSE)
dir.create("Logs",showWarnings = FALSE)
dir.create("Exports",showWarnings = FALSE)

############################################################
# ETAPE 1 : INITIALISATION AGENT
############################################################

print("-----------------------------------------")
print("ETAPE 1 : Initialisation Agent")
print("-----------------------------------------")

source("Scripts/01_initialisation_agent.R")

############################################################
# ETAPE 2 : PROFIL CANDIDAT
############################################################

print("-----------------------------------------")
print("ETAPE 2 : Profil candidat")
print("-----------------------------------------")

source("Scripts/02_moteur_recherche_canditat.R")

############################################################
# ETAPE 3 : CONFIGURATION DES SOURCES
############################################################

print("-----------------------------------------")
print("ETAPE 3 : Configuration des sources")
print("-----------------------------------------")

source("Scripts/03_configuration_sources_offres.R")

############################################################
# ETAPE 4 : VERIFICATION DES SOURCES (diagnostic)
############################################################
# Optionnel : teste juste la connexion, n'affecte pas la collecte
# elle-même. Peut être commenté pour aller plus vite si déjà
# validé récemment.

print("-----------------------------------------")
print("ETAPE 4 : Vérification des sources")
print("-----------------------------------------")

source("Scripts/03_1_test_connexion_sources.R")

############################################################
# ETAPE 5 : COLLECTE MULTI SOURCES
############################################################
# NOTE : l'ancien script "03_2_collecte_offres_reelles.R"
# (une ligne = une page entière) a été RETIRE du pipeline.
# Il est superseded par 03_2_1 + 03_2_2 qui collectent et
# nettoient de VRAIES offres individuelles, avec de meilleurs
# résultats validés le 24/07/2026 (JobIvoire, Talent.com CI,
# LinkedIn donnant des offres CI pertinentes).

print("-----------------------------------------")
print("ETAPE 5 : Collecte Multi Sources")
print("-----------------------------------------")

source("Scripts/03_2_1_collecte_offres_multi_sources.R")

############################################################
# ETAPE 6 : NETTOYAGE DES OFFRES
############################################################

print("-----------------------------------------")
print("ETAPE 6 : Nettoyage des offres")
print("-----------------------------------------")

source("Scripts/03_2_2_nettoyage_offres.R")

############################################################
# ETAPE 7 : SCORING DES OFFRES
############################################################

if(file.exists("Scripts/04_scoring_offres.R")){
  
  if(file.info("Scripts/04_scoring_offres.R")$size > 0){
    
    print("-----------------------------------------")
    print("ETAPE 7 : Scoring des offres")
    print("-----------------------------------------")
    
    source("Scripts/04_scoring_offres.R")
    
  }else{
    
    print("-----------------------------------------")
    print("Scoring non développé")
    print("-----------------------------------------")
    
  }
  
}

############################################################
# ETAPE 8 : ENVOI TELEGRAM
############################################################

if(file.exists("Scripts/05_envoi_telegram.R")){
  
  if(file.info("Scripts/05_envoi_telegram.R")$size > 0){
    
    print("-----------------------------------------")
    print("ETAPE 8 : Envoi Telegram")
    print("-----------------------------------------")
    
    source("Scripts/05_envoi_telegram.R")
    
  }else{
    
    print("-----------------------------------------")
    print("Envoi Telegram non développé")
    print("-----------------------------------------")
    
  }
  
}

############################################################
# FIN
############################################################

fin <- Sys.time()

print("")
print("=====================================================")
print(" JOB HUNTER CI TERMINE ")
print("=====================================================")

print(
  
  paste(
    
    "Temps total :",
    
    round(as.numeric(fin-debut),2),
    
    "secondes"
    
  )
  
)

print("")
print("Tous les résultats sont enregistrés dans le dossier Data.")