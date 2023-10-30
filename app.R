library(shiny)
library(gridlayout)
library(bslib)
library(tidyverse)
library(sf)
source("R/scripts.R")
options(shiny.maxRequestSize = 50 * 1024^2)


ui <- grid_page(
  shinyFeedback::useShinyFeedback(),
  layout = c(
    "header  header",
    "sidebar area2 "
  ),
  row_sizes = c(
    "100px",
    "1fr"
  ),
  col_sizes = c(
    "250px",
    "1fr"
  ),
  gap_size = "1rem",
  grid_card(
    area = "sidebar",
    card_body(
      "Ferramenta para cálculo de distância entre pontos georreferenciados de dados do Estudo Naturalístico de Direção Brasileiro.",
      fileInput("upload",
                strong("Selecionar arquivo: "),
                accept = ".gpkg",
                buttonLabel = HTML(paste(
                  icon("upload"),
                  "Procurar"
                )),
                placeholder = ""),
      textOutput("file_warning"),
      actionButton("calc",
                   label = "Calcular distância",
                   icon = icon("gears")),
      downloadButton("download_gpkg", "Baixar GPKG"),
      downloadButton("download_csv", "Baixar CSV")
    )
  ),
  grid_card_text(
    area = "header",
    content = "Cálculo de Distância entre Pontos",
    alignment = "center",
    is_title = FALSE
  ),
  grid_card(
    area = "area2",
    card_body(
      tabsetPanel(
        tabPanel("Tabela", 
                 shinycssloaders::withSpinner(tableOutput("table_output"),
                                              type = 8)),
        tabPanel("Sobre", p(includeMarkdown("sobre.md")))
      )
    ),
    textOutput("notif")
  )
)


server <- function(input, output) {
  
  file_warning <- reactive({
    req(input$upload)
    shinyFeedback::feedbackDanger(
      "upload",
      tools::file_ext(input$upload$name) != "gpkg",
      "Formato inválido"
    )
  })
  
  file_read <- reactive({
    req(input$upload)
    return(input$upload$datapath)
  })
  
  calc_results <- eventReactive(input$calc, {
    req(input$upload)
    
    data <- file_read() |> 
      st_read() |> 
      linestringer() |> 
      calc_dist()
    
    return(data)
  })
  
  make_table <- reactive({
    calc_results() |> 
      st_drop_geometry() |> 
      head(50)
  })
  
  output$file_warning <- renderText(file_warning())
  
  output$table_output <- renderTable(make_table())
  
}

shinyApp(ui, server)
  

