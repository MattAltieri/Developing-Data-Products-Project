require(shiny)

shinyUI(fluidPage(
    titlePanel("Phone Agent Productivity Coach"),
    fluidRow(
        column(2,
            selectInput("assoc", h4("Associate Name"), choices=NULL)),
        column(4,
            dateRangeInput("dates", h4("Select Date Range"))),
        column(2,
               br(),
               br(),
               submitButton("Submit"))
    ),
    hr()
))