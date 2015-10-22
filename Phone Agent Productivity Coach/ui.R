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
               #actionButton("submit", "Submit"))
               submitButton("Submit"))
    ),
    hr(),
    fluidRow(
        column(11,
               h3("Current Report Settings"))),
    fluidRow(
        column(3,
            htmlOutput("assoc")),
        column(5,
            htmlOutput("dates"))
    )
))