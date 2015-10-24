require(shiny)

shinyUI(fluidPage(
    titlePanel("Phone Agent Productivity Coach"),
    fluidRow(
        column(4,
               selectInput("assoc", h4("Associate Name"), choices=NULL),
               selectInput("metrics", h4("Metric"),
                           choices=NULL)),
        column(4,
               dateRangeInput("dates", h4("Select Date Range"),
                              start="2015-01-01"),
               selectInput("lvl_dtl", h4("Report Granularity"),
                           choices=NULL)),
        column(2,
               br(),
               br(),
               br(),
               br(),
               br(),
               br(),
               actionButton("submit", "Submit"))
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
               htmlOutput("metrics")),
        column(3,
               htmlOutput("rpts"))),
    hr(),
    fluidRow(
        column(12,
               plotOutput("prod.plot")))
))