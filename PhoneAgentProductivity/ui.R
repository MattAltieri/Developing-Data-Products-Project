require(shiny)

shinyUI(pageWithSidebar(
    headerPanel("Phone Agent Productivity Viewer"),
    sidebarPanel(
        h5(strong("Directions:")),
        helpText("Select a phone agent from the drop-down and hit submit",
              "to compare their productivity to that of their whole team."),
        br(),
        helpText("Date range, level of granularity, and which metric to plot",
              "can also be changed. The plot will be recalculated when you hit",
              "submit."),
        dateRangeInput("dates", h5("Select Date Range"), start="2015-01-01",
                       min="2015-01-01", max="2015-12-31"),
        selectInput("lvl_dtl", h5("Report Granularity"), choices=NULL),
        selectInput("assoc", h5("Associate Name"), choices=NULL),
        selectInput("metrics", h5("Metric"), choices=NULL),
        actionButton("submit", "Submit")
    ),
    mainPanel(
        htmlOutput("dates"),
        plotOutput("prod.plot"),
        br(),
        htmlOutput("defs")
    )
))