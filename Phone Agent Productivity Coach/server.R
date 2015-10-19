require(shiny)

associates <<- as.character(read.csv('./Data/Associate Names.csv')$Names)
prod.data <<- read.csv('./Data/Productivity Data.csv')

shinyServer(function(input, output, session) {
    
    observe({
        updateSelectInput(session, "assoc",
choices=c("Choose one"="",associates))
    })
})