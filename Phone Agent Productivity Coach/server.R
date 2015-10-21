require(shiny)
require(ggplot2)

associates <<- as.character(read.csv('./Data/Associate Names.csv')$Names)
prod.data <<- read.csv('./Data/Productivity Data.csv')
prod.data$Total.Call.Time <<- prod.data$Talk.Time + prod.data$Hold.Time +
    prod.data$Followup.Time

shinyServer(function(input, output, session) {
    
    observe({
        updateSelectInput(session, "assoc",
            choices=c("Choose one"="",associates))
    })

    output$assoc <- renderText({
        input$submit
        isolate(paste(strong("Productivity for:"),input$assoc))
    })
    output$dates <- renderText({
        input$submit
        isolate(paste(strong("Report Date:"),
                      input$dates[1],
                      "-",
                      input$dates[2]))
    })
})