library(shiny)
library(gridlayout)
library(bslib)
library(tidyverse)
library(sf)
library(knitr)
source("R/scripts.R")
options(shiny.maxRequestSize = 60 * 1024^2)


ui <- grid_page(
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
                accept = c("gpkg","shp"),
                buttonLabel = HTML(paste(
                  icon("upload"),
                  "Procurar"
                )),
                placeholder = ""),
      actionButton("button_input",
                   label = "Calcular distância",
                   icon = icon("gears")),
      downloadButton("download_gpkg", "Baixar GPKG"),
      downloadButton("download_csv", "Baixar CSV"),
      radioButtons(
        inputId = "radio_input",
        label = strong("Mostrar tabela:"),
        choices = list(
          "Tabela Original" = "table_1",
          "Tabela Calculada" = "table_2",
          "CSV" = "table_3"
        ),
        width = "100%"
      )
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
        tabPanel("Tabela", tableOutput("table_output")),
        tabPanel("Sobre", p(includeMarkdown("sobre.md")))
      )
    )
  )
)


server <- function(input, output) {
  
  show_data <- reactive({
    req(input$upload)

    input$upload$datapath |>
      st_read() |>
      st_drop_geometry() |>
      head(15)
  })
  
  output$table_output <- renderTable({
    show_data()
  })
  
}

shinyApp(ui, server)
  

