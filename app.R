library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(lubridate)
library(forcats)

# ==============================================================================
# 0. CHARGEMENT DES DONNÉES 
# ==============================================================================
df_patient_info  <- readRDS("dashboard_patient_info.rds")
df_resultats_rf  <- readRDS("dashboard_predictions_rf.rds")
df_clustering    <- readRDS("dashboard_data_profils.rds")
df_user_continu  <- readRDS("dashboard_cardio.rds")

modele_simu      <- readRDS("dashboard_modele_simu.rds")

user_info        <- readRDS("dashboard_user_info.rds")
sleep            <- readRDS("dashboard_sleep.rds")
activity_summary <- readRDS("dashboard_activity_summary.rds")
activity_plot    <- readRDS("dashboard_activity_plot.rds")

# ==============================================================================
# 1. INTERFACE UTILISATEUR (UI)
# ==============================================================================
ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(title = "Étude MMASH", titleWidth = 250),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dossier Patient", tabName = "onglet_patient", icon = icon("user-md")),
      menuItem("Exploration Globale", tabName = "onglet_eda", icon = icon("chart-bar")),
      menuItem("Profils de Vie", tabName = "onglet_cluster", icon = icon("users")),
      #menuItem("Simulateur d'IA", tabName = "onglet_simu", icon = icon("robot")),
      #menuItem("Simulateur de Sommeil", tabName = "onglet3", icon = icon("robot")),
      menuItem("Simulateur de Sommeil", tabName = "onglet4", icon = icon("robot"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # --- ONGLET 1 : DOSSIER PATIENT ---
      tabItem(tabName = "onglet_patient",
              h2("Suivi Clinique Individuel"),
              fluidRow(
                box(title = "Sélection", status = "primary", solidHeader = TRUE, width = 12,
                    selectInput("choix_patient", "", choices = unique(df_patient_info$Patient), width = "300px"))
              ),
              fluidRow(
                valueBoxOutput("box_imc", width = 4),
                valueBoxOutput("box_sommeil", width = 4),
                valueBoxOutput("box_efficacite", width = 4)
              ),
              fluidRow(
                box(title = "Chronogramme des Activités (48h)", status = "info", width = 12,
                    plotOutput("graph_chronogramme", height = "300px"))
              ),
              fluidRow(
                box(title = "Graphique de la fréquence cardiaque", status = "info", width = 12,
                    plotOutput("graph_cardio", height = "300px"))
              )
      ),
      
      # --- ONGLET 2 : EXPLORATION GLOBALE (NOUVEAU) ---
      tabItem(tabName = "onglet_eda",
              h2("Analyse de la Cohorte MMASH"),
              fluidRow(
                box(title = "Morphologie (Taille vs Poids)", status = "primary", width = 6,
                    plotOutput("graph_bmi")),
                box(title = "Temps de Sommeil vs Qualité (PSQI)", status = "primary", width = 6,
                    plotOutput("graph_tst_psqi"))
              ),
              fluidRow(
                box(title = "Densité de la Durée de Sommeil", status = "warning", width = 6,
                    plotOutput("graph_densite_sommeil")),
                box(title = "Durée moyenne quotidienne des activités", status = "success", width = 6,
                    plotOutput("graph_activite_barres"))
              )
      ),
      
      # --- ONGLET 3 : CLUSTERING ---
      tabItem(tabName = "onglet_cluster",
              h2("Clustering K-Means"),
              fluidRow(
                box(title = "Sédentarité vs Corpulence", status = "success", solidHeader = TRUE, width = 12,
                    plotOutput("graph_cluster", height = "500px"))
              )
      ),
      
      # --- ONGLET 4 : SIMULATEUR ---
      tabItem(tabName = "onglet_simu",
              h2("Prédiction de la Qualité du Sommeil"),
              fluidRow(
                box(title = "Paramètres Physiologiques", status = "warning", solidHeader = TRUE, width = 4,
                    sliderInput("sim_rr", "Rythme Cardiaque au repos (Mean_RR) :", min = 600, max = 1200, value = 850, step = 10),
                    sliderInput("sim_imc", "Indice de Masse Corporelle (IMC) :", min = 18, max = 35, value = 24, step = 0.5),
                    sliderInput("sim_eff", "Efficacité anticipée (%) :", min = 0.50, max = 1.00, value = 0.85, step = 0.01)),
                box(title = "Probabilité d'un Bon Sommeil (PSQI < 6)", status = "danger", solidHeader = TRUE, width = 8,
                    h1(textOutput("texte_prediction"), style = "color: #d9534f; font-weight: bold; text-align: center; margin-top: 50px; font-size: 60px;"))
              )
      ),
      
      # --- ONGLET 3 : SIMULATEUR ---
      tabItem(tabName = "onglet3",
              h2("Prédire la Qualité du Sommeil (Régression Logistique)"),
              fluidRow(
                box(
                  title = "Paramètres Physiologiques", status = "warning", solidHeader = TRUE, width = 4,
                  sliderInput("sim_rr", "Rythme Cardiaque au repos (Mean_RR) :", min = 600, max = 1200, value = 850, step = 10),
                  sliderInput("sim_imc", "Indice de Masse Corporelle (IMC) :", min = 18, max = 35, value = 24, step = 0.5),
                  sliderInput("sim_eff", "Efficacité anticipée du sommeil :", min = 0.50, max = 1.00, value = 0.85, step = 0.01)
                ),
                box(
                  title = "Résultat de l'IA", status = "danger", solidHeader = TRUE, width = 8,
                  h3("Probabilité d'avoir un Sommeil Réparateur (Score Pittsburgh < 6) :"),
                  h1(textOutput("texte_prediction2"), style = "color: #d9534f; font-weight: bold; text-align: center; margin-top: 50px; font-size: 60px;")
                )
              )
      ),
      
      # --- CONTENU ONGLET 3 : SIMULATEUR ---
      tabItem(tabName = "onglet4",
              h2("Prédire la Qualité du Sommeil"),
              fluidRow(
                box(
                  title = "Paramètres du Patient (La Dimension 3)", status = "warning", solidHeader = TRUE, width = 4,
                  sliderInput("sim_rr", "Rythme Cardiaque au repos (Mean_RR) :", min = 600, max = 1200, value = 900),
                  sliderInput("sim_melatonine", "Taux de Mélatonine au réveil :", min = 0, max = 10, value = 3, step = 0.5),
                  sliderInput("sim_activite", "Activité Physique (Index) :", min = 0, max = 50, value = 15)
                ),
                box(
                  title = "Résultat du Modèle d'Intelligence Artificielle", status = "danger", solidHeader = TRUE, width = 8,
                  h3("Probabilité d'avoir un Sommeil Réparateur :"),
                  h1(textOutput("texte_prediction3"), style = "color: #d9534f; font-weight: bold; text-align: center; margin-top: 50px;")
                )
              )
      )
    )
  )
)

# ==============================================================================
# 2. SERVEUR (Calculs et Graphiques)
# ==============================================================================
server <- function(input, output, session) {
  
  # ---------- ONGLET 1 : PATIENT ----------
  output$box_imc <- renderValueBox({
    info <- df_patient_info |> filter(Patient == input$choix_patient)
    val <- round(info$IMC, 1)
    valueBox(val, "IMC", icon = icon("weight"), color = if_else(val < 25, "green", "red"))
  })
  
  output$box_sommeil <- renderValueBox({
    info <- df_patient_info |> filter(Patient == input$choix_patient)
    h <- floor(info$Total.Sleep.Time..TST. / 60)
    m <- info$Total.Sleep.Time..TST. %% 60
    valueBox(paste0(h, "h ", sprintf("%02d", m), "m"), "Temps de Sommeil", icon = icon("bed"), color = if_else(info$Total.Sleep.Time..TST. >= 420, "aqua", "yellow"))
  })
  
  output$box_efficacite <- renderValueBox({
    info <- df_patient_info |> filter(Patient == input$choix_patient)
    val <- round(info$Efficiency * 100, 1) 
    valueBox(paste0(val, " %"), "Efficacité", icon = icon("battery-three-quarters"), color = if_else(val >= 85, "green", "orange"))
  })
  
  output$graph_chronogramme <- renderPlot({
    df_act <- activity_plot |> filter(Patient == input$choix_patient)
    ggplot(df_act) +
      geom_segment(aes(x = Start_dt, xend = End_dt, y = Activity_Label, yend = Activity_Label, color = Activity_Label), linewidth = 6) +
      scale_x_datetime(date_labels = "%H:%M", date_breaks = "4 hours") +
      theme_minimal(base_size = 14) +
      theme(legend.position = "none", panel.grid.minor.x = element_blank()) +
      labs(x = "Heure", y = "")
  })
  
  output$graph_cardio <- renderPlot({
    df_rr_continu <- df_user_continu |> filter(user_id == input$choix_patient)
    ggplot(df_rr_continu, aes(x = temps_continu, y = mean_hr, color = as.factor(day))) +
      geom_line(alpha = 0.6) +
      geom_vline(xintercept = 24, linetype = "dashed", color = "grey40", linewidth = 0.8) +
      scale_x_continuous(
        breaks = seq(0, 48, by = 4), 
        labels = function(x) paste0(x%%24, "h")
      ) +
      scale_color_manual(values = c("1" = "#3498db", "2" = "#e67e22")) +
      labs(
        x = "Temps (heures)",
        y = "BPM moyen",
        color = "Jour"
      ) +
      theme_minimal()
  })
  
  # ---------- ONGLET 2 : EXPLORATION ----------
  output$graph_bmi <- renderPlot({
    user_info$BMI <- user_info$Weight / ((user_info$Height/100)^2)
    ggplot(user_info, aes(x = Height, y = Weight)) +
      geom_point(aes(colour = BMI), size = 4, alpha = 0.8) +
      scale_colour_viridis_c(option = "plasma") +
      theme_minimal(base_size = 14) + labs(x = "Taille (cm)", y = "Poids (kg)")
  })
  
  output$graph_densite_sommeil <- renderPlot({
    ggplot(sleep, aes(Total.Sleep.Time..TST.)) +
      geom_density(alpha = 0.5, fill = "#3498db", color = "white") +
      scale_x_continuous(breaks = seq(0, 1000, by = 60), labels = function(x) paste0(x / 60, "h")) +
      theme_minimal(base_size = 14) + labs(x = "Temps de sommeil", y = "Densité")
  })
  
  output$graph_activite_barres <- renderPlot({
    ggplot(activity_summary, aes(x = fct_reorder(Activity_Label, Mean_Duration, .desc = TRUE), y = Mean_Duration, fill = Activity_Label)) +
      geom_col(alpha = 0.9) +
      geom_errorbar(aes(ymin = Mean_Duration - SE_Duration, ymax = Mean_Duration + SE_Duration), width = 0.2) +
      theme_minimal(base_size = 14) +
      theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "", y = "Heures")
  })
  
  output$graph_tst_psqi <- renderPlot({
    df_merge <- merge(sleep, df_patient_info, by = "Patient")
    ggplot(df_merge, aes(x = Total.Sleep.Time..TST..x, y = Pittsburgh)) +
      geom_point(size = 3, color = "#2c3e50") +
      geom_hline(yintercept = 6, linetype = "dashed", color = "#e74c3c") +
      scale_x_continuous(breaks = seq(60, 600, by = 60), labels = function(x) paste0(x/60, "h")) +
      theme_minimal(base_size = 14) + labs(x = "Temps de sommeil total", y = "Score PSQI")
  })
  
  # ---------- ONGLET 3 : CLUSTERING ----------
  output$graph_cluster <- renderPlot({
    ggplot(df_clustering, aes(x = IMC, y = Score_Activite/mean(Score_Activite), color = Profil, fill = Profil)) +
      geom_point(size = 5, alpha = 0.8) +
      stat_ellipse(geom = "polygon", alpha = 0.2, level = 0.80) +
      scale_color_manual(values = c("#00AFBB", "#FC4E07")) +
      scale_fill_manual(values = c("#00AFBB", "#FC4E07")) +
      theme_minimal(base_size = 18) + labs(x = "IMC", y = "Index de Sédentarité")
  })
  
  # ---------- ONGLET 4 : SIMULATEUR ----------
  output$texte_prediction <- renderText({
    nouveau_patient <- data.frame(Mean_RR = input$sim_rr, IMC = input$sim_imc, Efficiency = input$sim_eff)
    prob <- predict(modele_simu, newdata = nouveau_patient, type = "response")
    paste0(round(prob * 100, 1), " %")
  })
  
  # --- LOGIQUE ONGLET 3 : Simulateur (Régression Logistique) ---
  output$texte_prediction2 <- renderText({
    # 1. On rassemble les valeurs des curseurs dans un dataframe
    nouveau_patient2 <- data.frame(
      Mean_RR = input$sim_rr,
      IMC = input$sim_imc,
      Efficiency = input$sim_eff
    )
    
    # 2. Prédiction avec le modèle sauvegardé
    prob2 <- predict(modele_simu, newdata = nouveau_patient2, type = "response")
    
    # 3. Formatage de l'affichage
    paste0(round(prob2 * 100, 1), " %")
  })
  
  output$texte_prediction3 <- renderText({
    # Ici, vous devrez mettre le vrai code predict(modele_pcr, newdata = ...)
    # En attendant, voici une petite formule factice pour que le dashboard réagisse :
    
    # Plus le RR est haut (cœur lent) et la mélatonine basse, plus on s'approche de 100%
    score_fictif <- (input$sim_rr / 1200) * 50 + ((10 - input$sim_melatonine) / 10) * 30 + (input$sim_activite / 50) * 20
    
    paste0(round(score_fictif, 1), " %")
  })
}

shinyApp(ui, server)