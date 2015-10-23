require(shiny)

shinyUI(fluidPage(
    titlePanel("Phone Agent Productivity Coach"),
    fluidRow(
        column(2,
               selectInput("assoc", h4("Associate Name"), choices=NULL)),
        column(4,
               dateRangeInput("dates", h4("Select Date Range")),
               selectInput("lvl_dtl", h4("Report Granularity"),
                           choices=NULL)),
        column(3,
               selectInput("rpts", h4("Comparison Report"),
                           choices=NULL)),
        column(2,
               br(),
               br(),
               actionButton("submit", "Submit"))
               #submitButton("Submit"))
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
    ),
    fluidRow(
        column(3,
               htmlOutput("lvl_dtl")),
        column(3,
               htmlOutput("rpts"))),
    fluidRow(
        column(12,
               tableOutput("assoc.table"))),
    fluidRow(
        column(12,
               tableOutput("sum.table")))
))