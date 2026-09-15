# ==========================================
# JOB HUNTER CI
# Script 04_2 : Collecte Novojob V2
# ==========================================


rm(list = ls())


print("================================")
print("JOB HUNTER CI - COLLECTE NOVOJOB")
print("================================")


library(chromote)
library(rvest)
library(stringr)
library(dplyr)



print("Connexion Chrome...")


chrome <- ChromoteSession$new()


print("Chrome OK")



# ==========================================
# URL
# ==========================================


url <- "https://www.novojob.com/cote-d-ivoire/offres-d-emploi/data-analyst"


print("Ouverture page :")
print(url)



# Navigation sans attendre la fin complète

tryCatch({
  
  chrome$Page$navigate(
    url,
    wait_ = FALSE
  )
  
}, error = function(e){
  
  print("Navigation lancée malgré timeout")
  
})



Sys.sleep(15)



print("Chargement terminé")



# ==========================================
# RECUPERATION PAGE
# ==========================================


html <- chrome$Runtime$evaluate(
  "document.documentElement.outerHTML"
)



contenu <- html$result$value



page <- read_html(contenu)



print("HTML récupéré")



# ==========================================
# EXTRACTION TEXTE PAGE
# ==========================================


texte_page <- page %>%
  html_text2()



print("Aperçu contenu :")

print(
  substr(
    texte_page,
    1,
    500
  )
)



# ==========================================
# EXTRACTION LIENS
# ==========================================


liens <- page %>%
  html_elements("a") %>%
  html_attr("href")



liens <- liens[
  !is.na(liens)
]



offres <- liens[
  str_detect(
    liens,
    "emploi|job|offre"
  )
]



print(
  paste(
    "Nombre de liens détectés :",
    length(offres)
  )
)



# ==========================================
# RESULTAT
# ==========================================


resultat_novojob <- data.frame(
  
  source = "Novojob",
  
  date_collecte = Sys.Date(),
  
  lien = unique(offres),
  
  stringsAsFactors = FALSE
  
)



print("--------------------------------")

print(resultat_novojob)


print("--------------------------------")

print("COLLECTE NOVOJOB TERMINEE")