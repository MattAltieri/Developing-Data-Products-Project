require(shiny)

shinyUI(fluidPage(
    titlePanel("Phone Agent Productivity Coach"),
    verticalLayout(
        selectInput("assoc", "Associate Name", choices=NULL)
    )
))