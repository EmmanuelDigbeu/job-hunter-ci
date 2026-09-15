# ==========================================
# JOB HUNTER CI
# Script 03 : Configuration sources OFFRES REELLES
# VERSION CORRIGEE (URLs réparées + sources CI ajoutées
# + désactivation des sources bruyantes/non pertinentes)
# ==========================================

rm(list = ls())

print("================================")
print("JOB HUNTER CI - CONFIG SOURCES V3")
print("================================")

date_recherche <- Sys.Date()

print(
  paste(
    "Date recherche :",
    date_recherche
  )
)

# ==========================================
# SOURCES CONFIGUREES
# ==========================================
# NOTE IMPORTANTE :
# - PNUD / UNICEF / BAD / Glassdoor / Google Jobs / Wave / Indeed /
#   Jooble sont DESACTIVEES (actif = FALSE) : analyse du 24/07/2026
#   a montré qu'elles génèrent 96% de bruit (offres hors-sujet ou
#   non-CI) ou ne fonctionnent pas techniquement (DNS/timeout/JS).
# - Emploi.ci et Africawork restent configurées mais désactivées
#   (protection Cloudflare "Just a moment..." non contournée).
# - MTN, Moov, JobIvoire, AfricSearch : URLs corrigées (anciennes
#   URLs en 404).
# - 3 nouvelles sources CI ajoutées, actives et vérifiées récentes
#   (Educarriere.ci, Talent.com CI, Projobivoire).

sources <- data.frame(
  
  id_source = 1:23,
  
  
  nom_source = c(
    
    "Emploi.ci",
    "Novojob",
    "Africawork",
    "JobIvoire",
    "Indeed",
    "Jooble",
    "OptionCarriere",
    "LinkedIn Jobs",
    "Glassdoor",
    "Google Jobs",
    
    "Orange Careers",
    "MTN CI Careers",
    "Moov Africa Careers",
    "Wave Careers",
    
    "RMO Job Center",
    "AfricSearch",
    "Talent2Africa",
    
    "PNUD",
    "BAD",
    "UNICEF",
    
    "Educarriere.ci",
    "Talent.com CI",
    "Projobivoire"
    
  ),
  
  
  
  # ==========================================
  # URL RECHERCHE OFFRES
  # ==========================================
  
  
  url_recherche = c(
    
    
    "https://www.emploi.ci/recherche?q=data+analyst",
    
    "https://www.novojob.com/cote-d-ivoire/offres-emploi/data-analyst",
    
    "https://www.africawork.com/jobs?search=data+analyst",
    
    # CORRIGE : ancienne URL "/recherche?keyword=data" était en 404
    "https://www.jobivoire.ci/job",
    
    "https://www.indeed.com/jobs?q=data+analyst&l=Cote+d%27Ivoire",
    
    "https://www.jooble.org/SearchResult?rgns=C%C3%B4te+d%27Ivoire&ukw=data+analyst",
    
    "https://www.optioncarriere.ci/emploi-data-analyst.html",
    
    "https://www.linkedin.com/jobs/search/?keywords=data%20analyst&geoId=102902401",
    
    "https://www.glassdoor.com/Job/cote-d-ivoire-data-analyst-jobs",
    
    "https://www.google.com/search?q=data+analyst+jobs+cote+d%27ivoire",
    
    
    "https://orange.jobs/en/search/?q=data",
    
    # CORRIGE : ancienne URL "/carrieres" était en 404, la vraie est "/careers/"
    "https://www.mtn.ci/careers/",
    
    # CORRIGE : ancienne URL "/carrieres" était en 404, la vraie est "/carriere/" (singulier)
    "https://www.moov-africa.ci/carriere/",
    
    "https://careers.wave.com",
    
    
    "https://www.rmo-jobcenter.com/offres",
    
    # CORRIGE : ancienne URL "/jobs" était en 404
    "https://africsearch.com/index_fr/candidat/job",
    
    "https://talent2africa.com/jobs",
    
    
    "https://jobs.undp.org/cj_view_jobs.cfm?search=data",
    
    "https://afdb.jobs2web.com/search/?q=data",
    
    "https://jobs.unicef.org/en-us/search/?search=data",
    
    
    # NOUVEAU : plateforme emploi CI active (offres datées 2026 confirmées)
    "https://emploi.educarriere.ci/nos-offres",
    
    # NOUVEAU : agrégateur international actif en CI, recherche ciblée Abidjan
    "https://ci.talent.com/fr/jobs/k-data-analyst-l-abidjan",
    
    # NOUVEAU : plateforme emploi CI active (offres récentes confirmées)
    "https://projobivoire.com/"
    
    
  ),
  
  
  
  # ==========================================
  # TYPE SOURCE
  # ==========================================
  
  
  type_source = c(
    
    rep("Job Board",10),
    
    rep("Entreprise",4),
    
    rep("Cabinet RH",3),
    
    rep("Organisation Internationale",3),
    
    rep("Job Board",3)
    
  ),
  
  
  
  # ==========================================
  # METHODE COLLECTE
  # ==========================================
  
  
  methode_collecte = c(
    
    "Scraping HTML",
    "Scraping HTML",
    "Scraping HTML",
    "Scraping HTML",
    
    "Recherche Web",
    "Scraping HTML",
    "Scraping HTML",
    
    "Recherche Web",
    "Recherche Web",
    "Recherche Web",
    
    "Page carrière",
    "Page carrière",
    "Page carrière",
    "Page carrière",
    
    "Scraping HTML",
    "Scraping HTML",
    "Scraping HTML",
    
    "Scraping HTML",
    "Scraping HTML",
    "Scraping HTML",
    
    "Scraping HTML",
    "Scraping HTML",
    "Scraping HTML"
    
  ),
  
  
  
  # ==========================================
  # MOTS CLES PAR SOURCE
  # ==========================================
  
  
  mots_recherche = rep(
    
    "data analyst|business analyst|power bi|sql|reporting|bi analyst|data engineer|python",
    
    23
    
  ),
  
  
  
  # ==========================================
  # PRIORITE
  # ==========================================
  
  
  priorite = c(
    
    "Haute",
    "Haute",
    "Haute",
    "Haute",
    
    "Moyenne",
    "Moyenne",
    "Moyenne",
    
    "Haute",
    "Moyenne",
    "Moyenne",
    
    "Haute",
    "Haute",
    "Moyenne",
    "Moyenne",
    
    "Haute",
    "Moyenne",
    "Moyenne",
    
    "Haute",
    "Haute",
    "Haute",
    
    "Haute",
    "Haute",
    "Haute"
    
  ),
  
  
  
  # ==========================================
  # ACTIVATION
  # ==========================================
  # FALSE = source désactivée (bloquée techniquement OU
  # confirmée non pertinente pour l'objectif "offres data en CI")
  
  
  actif = c(
    
    FALSE,  # Emploi.ci - Cloudflare bloque le scraping
    TRUE,   # Novojob
    FALSE,  # Africawork - Cloudflare bloque le scraping
    TRUE,   # JobIvoire - URL corrigée
    FALSE,  # Indeed - liens non détectés, contenu international
    FALSE,  # Jooble - timeout systématique
    TRUE,   # OptionCarriere
    TRUE,   # LinkedIn Jobs
    FALSE,  # Glassdoor - 1 seul lien cassé obtenu
    FALSE,  # Google Jobs - contenu vide systématique
    
    TRUE,   # Orange Careers
    TRUE,   # MTN CI Careers - URL corrigée
    TRUE,   # Moov Africa Careers - URL corrigée
    FALSE,  # Wave Careers - domaine introuvable (DNS)
    
    FALSE,  # RMO Job Center - contenu vide systématique
    TRUE,   # AfricSearch - URL corrigée
    TRUE,   # Talent2Africa
    
    FALSE,  # PNUD - 96% de bruit confirmé (postes hors-sujet, pas CI)
    FALSE,  # BAD - échantillon trop faible et non pertinent
    FALSE,  # UNICEF - même problème que PNUD
    
    TRUE,   # Educarriere.ci - nouveau, actif CI
    TRUE,   # Talent.com CI - nouveau, actif CI
    TRUE    # Projobivoire - nouveau, actif CI
    
  ),
  
  
  
  # ==========================================
  # STATUT CONNEXION
  # ==========================================
  
  
  statut = "A tester",
  
  
  stringsAsFactors = FALSE
  
  
)

# ==========================================
# VERIFICATION
# ==========================================

print("--------------------------------")

print(
  paste(
    "Nombre sources configurées :",
    nrow(sources)
  )
)

print(
  paste(
    "Sources actives :",
    sum(sources$actif)
  )
)

print("--------------------------------")

print(
  "Configuration sources V3 chargée"
)

print(
  "JOB HUNTER CI - SOURCES PRETES"
)