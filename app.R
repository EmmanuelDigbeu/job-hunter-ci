##############################################
# JOB HUNTER CI - Demo Shiny (v2)
# Vitrine interactive du moteur de scoring
##############################################

library(shiny)
library(DT)
library(dplyr)
library(ggplot2)

# ------------------------------------------------------
# Échantillon réel de résultats produits par le pipeline
# ------------------------------------------------------
offres <- data.frame(
  date = as.Date(c(
    "2026-08-14","2026-08-14","2026-08-14",
    "2026-08-15","2026-08-15","2026-08-15",
    "2026-08-17","2026-08-17","2026-08-17",
    "2026-08-19","2026-08-19","2026-08-19",
    "2026-08-20","2026-08-21",
    "2026-08-22","2026-08-22",
    "2026-08-24"
  )),
  titre = c(
    "Data Analyst — Abidjan (Talent.com)",
    "Azure Data Engineer — Epergne Solutions",
    "Gen AI | ML Data Scientist — Quadratyx",
    "Data Analyst — Abidjan (Talent.com)",
    "Azure Data Engineer — Epergne Solutions",
    "Gen AI | ML Data Scientist — Quadratyx",
    "Data Analyst — Abidjan (Talent.com)",
    "Azure Data Engineer — Epergne Solutions",
    "Gen AI | ML Data Scientist — Quadratyx",
    "Data Analyst — Abidjan (Talent.com)",
    "Azure Data Engineer — Epergne Solutions",
    "Gen AI | ML Data Scientist — Quadratyx",
    "Data Analyst — Abidjan (Talent.com)",
    "Data Analyst — Abidjan (Talent.com)",
    "Data Analyst — Abidjan (Talent.com)",
    "Gen AI | ML Data Scientist — Quadratyx",
    "Data Analyst — Abidjan (Talent.com)"
  ),
  ville_ciblee = "Abidjan",
  source = c(
    "Talent.com CI","LinkedIn Jobs","LinkedIn Jobs",
    "Talent.com CI","LinkedIn Jobs","LinkedIn Jobs",
    "Talent.com CI","LinkedIn Jobs","LinkedIn Jobs",
    "Talent.com CI","LinkedIn Jobs","LinkedIn Jobs",
    "Talent.com CI","Talent.com CI",
    "Talent.com CI","LinkedIn Jobs",
    "Talent.com CI"
  ),
  contrat = c(
    "Consultant","Non précisé","Non précisé",
    "Non précisé","Non précisé","Non précisé",
    "Non précisé","Non précisé","Non précisé",
    "Non précisé","Non précisé","Non précisé",
    "Non précisé","Non précisé",
    "Non précisé","Non précisé",
    "Non précisé"
  ),
  score = c(75, 45, 45,
            100, 45, 45,
            100, 45, 45,
            100, 45, 45,
            73, 73,
            83, 41,
            73),
  stringsAsFactors = FALSE
)

offres$niveau <- cut(
  offres$score,
  breaks = c(-Inf, 50, 70, Inf),
  labels = c("Faible", "Moyen", "Excellent")
)

badge <- function(niveau) {
  couleur <- c("Faible" = "#ef4444", "Moyen" = "#f59e0b", "Excellent" = "#22c55e")[as.character(niveau)]
  sprintf('<span style="background:%s22;color:%s;padding:3px 10px;border-radius:12px;font-size:12px;font-weight:600;">%s</span>',
          couleur, couleur, niveau)
}

# ------------------------------------------------------
# Interface
# ------------------------------------------------------
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body {
      background: #0b0d13;
      color: #e5e7eb;
      font-family: 'Inter','Segoe UI',sans-serif;
    }
    .container-fluid { padding: 24px 32px; }
    .app-title { font-size: 26px; font-weight: 700; color: #fff; margin-bottom: 4px; }
    .app-sub { font-size: 14px; color: #9ca3af; margin-bottom: 24px; }
    .metric {
      background: linear-gradient(145deg,#161923,#11141c);
      border: 1px solid #1f2430;
      border-radius: 14px;
      padding: 18px;
      text-align: left;
      margin-bottom: 18px;
    }
    .metric .value { font-size: 30px; font-weight: 700; color: #f9fafb; line-height: 1.1; }
    .metric .label { font-size: 12px; color: #8b93a3; text-transform: uppercase; letter-spacing: .6px; margin-top: 6px; }
    .panel-box {
      background: #11141c;
      border: 1px solid #1f2430;
      border-radius: 14px;
      padding: 18px;
    }
    .well { background: #11141c !important; border: 1px solid #1f2430 !important; border-radius: 14px; }
    h4 { color: #e5e7eb; font-size: 15px; font-weight: 600; margin-top: 0; }
    .empty-msg {
      text-align: center; padding: 40px 20px; color: #6b7280;
      background: #11141c; border: 1px dashed #2a3040; border-radius: 14px;
    }
    table.dataTable { color: #d1d5db !important; }
    table.dataTable thead th { color: #9ca3af !important; border-bottom: 1px solid #1f2430 !important; }
    table.dataTable tbody tr { background: transparent !important; }
    table.dataTable tbody td { border-top: 1px solid #161a24 !important; }
    .dataTables_wrapper .dataTables_paginate .paginate_button { color: #9ca3af !important; }
    .dataTables_filter input, .dataTables_length select { background:#0b0d13; color:#e5e7eb; border:1px solid #1f2430; border-radius:6px; }
    .irs-bar, .irs-single { background: #22c55e !important; border-color: #22c55e !important; }
    .note { font-size: 12px; color: #6b7280; line-height: 1.5; }
  "))),
  
  div(class = "app-title", "JOB HUNTER CI"),
  div(class = "app-sub", "Moteur automatisé de collecte et de scoring d'offres d'emploi — démo interactive"),
  
  fluidRow(
    column(3, div(class = "metric", div(class = "value", textOutput("nb_offres")), div(class = "label", "Offres affichées"))),
    column(3, div(class = "metric", div(class = "value", textOutput("score_moyen")), div(class = "label", "Score moyen /100"))),
    column(3, div(class = "metric", div(class = "value", textOutput("nb_excellent")), div(class = "label", "Niveau Excellent"))),
    column(3, div(class = "metric", div(class = "value", textOutput("nb_sources")), div(class = "label", "Sources actives")))
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Filtres"),
      sliderInput("score_min", "Score minimum", min = 0, max = 100, value = 0, step = 5),
      uiOutput("source_ui"),
      uiOutput("niveau_ui"),
      actionButton("reset", "Réinitialiser", class = "btn-sm", style = "width:100%;margin-top:10px;background:#1f2430;color:#e5e7eb;border:none;"),
      hr(style = "border-color:#1f2430;"),
      div(class = "note",
          strong("Comment lire le score ?"), br(),
          "Le score combine la pertinence du titre, la présence de mots-clés distinctifs et la localisation. ",
          "Une offre hors zone cible est fortement pénalisée.", br(), br(),
          "Échantillon de résultats réellement produits par le pipeline et livrés via Telegram."
      )
    ),
    
    mainPanel(
      width = 9,
      fluidRow(
        column(6, div(class = "panel-box", style = "margin-bottom:18px;",
                      h4("Distribution des scores"),
                      plotOutput("graph_histo", height = "220px")
        )),
        column(6, div(class = "panel-box", style = "margin-bottom:18px;",
                      h4("Évolution dans le temps"),
                      plotOutput("graph_evolution", height = "220px")
        ))
      ),
      uiOutput("table_ou_message")
    )
  )
)

# ------------------------------------------------------
# Serveur
# ------------------------------------------------------
server <- function(input, output, session) {
  
  # Filtre source (toujours complet)
  output$source_ui <- renderUI({
    selectInput("source_filter", "Source",
                choices = c("Toutes", sort(unique(offres$source))),
                selected = "Toutes")
  })
  
  # Filtre niveau adaptatif : ne propose que les niveaux réellement disponibles
  output$niveau_ui <- renderUI({
    src <- input$source_filter
    d <- offres %>% filter(score >= input$score_min)
    if (!is.null(src) && src != "Toutes") d <- d %>% filter(source == src)
    dispo <- sort(unique(as.character(d$niveau)))
    selectInput("niveau_filter", "Niveau",
                choices = c("Tous", dispo),
                selected = "Tous")
  })
  
  observeEvent(input$reset, {
    updateSliderInput(session, "score_min", value = 0)
    updateSelectInput(session, "source_filter", selected = "Toutes")
    updateSelectInput(session, "niveau_filter", selected = "Tous")
  })
  
  offres_filtrees <- reactive({
    d <- offres %>% filter(score >= input$score_min)
    if (!is.null(input$source_filter) && input$source_filter != "Toutes") {
      d <- d %>% filter(source == input$source_filter)
    }
    if (!is.null(input$niveau_filter) && input$niveau_filter != "Tous") {
      d <- d %>% filter(as.character(niveau) == input$niveau_filter)
    }
    d
  })
  
  output$nb_offres    <- renderText({ nrow(offres_filtrees()) })
  output$score_moyen  <- renderText({
    d <- offres_filtrees()
    if (nrow(d) == 0) "—" else round(mean(d$score), 0)
  })
  output$nb_excellent <- renderText({ sum(as.character(offres_filtrees()$niveau) == "Excellent") })
  output$nb_sources   <- renderText({ length(unique(offres_filtrees()$source)) })
  
  tema_sombre <- theme_minimal(base_size = 12) +
    theme(
      plot.background  = element_rect(fill = "#11141c", color = NA),
      panel.background = element_rect(fill = "#11141c", color = NA),
      panel.grid.major = element_line(color = "#1b1f2a"),
      panel.grid.minor = element_blank(),
      text = element_text(color = "#9ca3af"),
      axis.text = element_text(color = "#9ca3af"),
      legend.position = "top",
      legend.text = element_text(color = "#9ca3af"),
      legend.title = element_blank()
    )
  
  output$graph_histo <- renderPlot({
    d <- offres_filtrees()
    if (nrow(d) == 0) return(NULL)
    ggplot(d, aes(x = score, fill = niveau)) +
      geom_histogram(binwidth = 10, boundary = 0, color = "#0b0d13", alpha = .95) +
      scale_fill_manual(values = c("Faible" = "#ef4444", "Moyen" = "#f59e0b", "Excellent" = "#22c55e"), drop = FALSE) +
      labs(x = "Score /100", y = "Nombre d'offres") +
      xlim(0, 105) +
      tema_sombre
  }, bg = "transparent")
  
  output$graph_evolution <- renderPlot({
    d <- offres_filtrees()
    if (nrow(d) == 0) return(NULL)
    d_jour <- d %>%
      group_by(date) %>%
      summarise(nb = n(), score_moy = mean(score), .groups = "drop")
    
    ggplot(d_jour, aes(x = date)) +
      geom_col(aes(y = nb), fill = "#1f2430", width = 0.6) +
      geom_line(aes(y = score_moy / 100 * max(d_jour$nb, 1)), color = "#22c55e", linewidth = 1) +
      geom_point(aes(y = score_moy / 100 * max(d_jour$nb, 1)), color = "#22c55e", size = 2) +
      scale_y_continuous(
        name = "Nb d'offres (barres)",
        sec.axis = sec_axis(~ . / max(d_jour$nb, 1) * 100, name = "Score moyen (ligne)")
      ) +
      labs(x = NULL) +
      tema_sombre +
      theme(axis.title.y.right = element_text(color = "#22c55e"))
  }, bg = "transparent")
  
  output$table_ou_message <- renderUI({
    if (nrow(offres_filtrees()) == 0) {
      div(class = "empty-msg",
          h4("Aucune offre ne correspond à ces critères"),
          p("Essaie de baisser le score minimum ou de réinitialiser les filtres.")
      )
    } else {
      div(class = "panel-box", DTOutput("table_offres"))
    }
  })
  
  output$table_offres <- renderDT({
    d <- offres_filtrees() %>%
      arrange(desc(score)) %>%
      mutate(Niveau = sapply(niveau, badge)) %>%
      select(Date = date, Offre = titre, Source = source, Contrat = contrat, Score = score, Niveau)
    
    datatable(
      d,
      escape = FALSE,
      rownames = FALSE,
      options = list(
        pageLength = 8,
        dom = 'ftp',
        language = list(
          search = "Rechercher :",
          paginate = list(previous = "Préc.", `next` = "Suiv."),
          zeroRecords = "Aucun résultat",
          info = ""
        )
      )
    )
  })
}

shinyApp(ui, server)