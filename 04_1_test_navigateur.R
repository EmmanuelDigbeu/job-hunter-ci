# ==========================================
# JOB HUNTER CI
# Script 04_1 : Test Chrome automatique
# ==========================================


rm(list = ls())


print("================================")
print("TEST CHROME JOB HUNTER CI")
print("================================")


library(chromote)



print("Ouverture session Chrome...")


chrome <- ChromoteSession$new()


print("Chrome connecté")



# Ouverture Novojob

chrome$Page$navigate(
  "https://www.novojob.com"
)


print("Navigation vers Novojob effectuée")



Sys.sleep(5)



# Récupération du titre de la page

resultat <- chrome$Runtime$evaluate(
  "document.title"
)



print("Titre de la page :")

print(
  resultat$result$value
)



print("TEST TERMINE")