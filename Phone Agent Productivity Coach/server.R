require(shiny)
require(ggplot2)
require(dplyr)
require(lubridate)

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
        paste(strong("Productivity for:"),input$assoc)
    })
    output$dates <- renderText({
        paste(strong("Report Date:"),
              input$dates[1],
              "to",
              input$dates[2])
    })
    
    output$prod.plot <- renderPlot({
        # Need selector for stat to examine
        # Pull field names, add name of stat being calculated
        # Use selector to add field for stat being calculated
        # Apply names vector back to dataframe names
        # Summarize data
        # Plot data
        assoc.data <- prod.data[which(prod.data==input$assoc),] %>%
            group_by(week(Date)) %>%
            summarize(sum(Calls),
                      weighted.mean(Talk.Time, Calls),
                      weighted.mean(Hold.Time, Calls),
                      weighted.mean(Followup.Time, Calls),
                      weighted.mean(Total.Call.Time, Calls))
        sum.data <- prod.data %>%
            group_by(week(Date)) %>%
            summarize(sum(Calls),
                      weighted.mean(Talk.Time, Calls),
                      weighted.mean(Hold.Time, Calls),
                      weighted.mean(Followup.Time, Calls),
                      weighted.mean(Total.Call.Time, Calls))
        ggplot()
    })
})