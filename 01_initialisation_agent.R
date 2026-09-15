# ==========================================
# JOB HUNTER CI
# Script 01 : Initialisation Agent 
# ==========================================
rm(list = setdiff(ls(envir = .GlobalEnv), "debut"))

print("================================")
print("JOB HUNTER CI - INITIALISATION AGENT")
print("================================")

# ==========================================
# DATE EXECUTION
# ==========================================
date_execution <- Sys.Date()
print(
  paste(
    "Date execution :",
    date_execution
  )
)

# ==========================================
# VERIFICATION DOSSIERS
# ==========================================
dossiers <- c(
  "Data",
  "Config",
  "Scripts",
  "Logs"
)

for(d in dossiers){
  if(!dir.exists(d)){
    dir.create(d)
    print(
      paste(
        "Dossier créé :",
        d
      )
    )
  }
}

# ==========================================
# CHARGEMENT PROFIL
# ==========================================
fichier_profil <- "Config/profil_emmanuel.txt"
if(!file.exists(fichier_profil)){
  stop(
    paste(
      "Profil introuvable :",
      fichier_profil
    )
  )
}

profil_texte <- readLines(
  fichier_profil,
  encoding = "UTF-8"
)
print(
  paste(
    "Profil chargé :",
    length(profil_texte),
    "lignes"
  )
)

# ==========================================
# PROFIL STRUCTURE
# ==========================================
profil_candidat <- list(
  nom = "Emmanuel",
  pays = "Côte d'Ivoire",
  ville = "Abidjan",
  metiers_cibles = c(
    "Data Analyst",
    "BI Analyst",
    "Business Analyst",
    "Reporting Analyst",
    "Data Engineer Junior",
    "Data Scientist Junior"
  ),
  competences = c(
    "Power BI",
    "DAX",
    "Power Query",
    "SQL",
    "Python",
    "R",
    "Excel",
    "Reporting",
    "Dashboard",
    "KPI",
    "Analyse statistique"
  ),
  experience = "2-3 ans",
  niveau = c(
    "Junior",
    "Intermediaire"
  ),
  mobilite = c(
    "Abidjan",
    "Côte d'Ivoire",
    "Remote"
  )
)

# ==========================================
# SAUVEGARDE SESSION
# ==========================================
save(
  profil_candidat,
  file = "Data/profil_candidat.RData"
)
print("Profil candidat structuré sauvegardé")

# ==========================================
# FIN
# ==========================================
print("--------------------------------")
print(
  "JOB HUNTER CI INITIALISATION TERMINE"
)
print("--------------------------------")