require(shiny)
require(ggplot2)
require(ggthemes)
require(dplyr)
require(lubridate)
require(lazyeval)
tableau <<- tableau_color_pal("tableau10")(2)

# Load data and do basic processing
associates <<- as.character(read.csv('./Data/Associate Names.csv')$Names)
prod.data <<- read.csv('./Data/Productivity Data.csv')
prod.data$Total.Time <<- prod.data$Talk.Time + prod.data$Hold.Time +
    prod.data$Followup.Time
prod.data <<- mutate(prod.data, Date=mdy(Date))

# Track submissions for the session
submits <<- 0

# Define contents of other dropdowns, and how they map to function names or
# prod.data field
lvl.dtl <<- as.data.frame(rbind(
        c("Weekly","week"),
        c("Monthly","month"),
        c("Quarterly","quarter")),
    stringsAsFactors=F)
names(lvl.dtl) <<- c("name","func")

reports <<- as.data.frame(rbind(
        c("Talk Time","Talk.Time"),
        c("Hold Time","Hold.Time"),
        c("Followup Time","Followup.Time"),
        c("Total Time","Total.Time")),
    stringsAsFactors=F)
names(reports) <<- c("name","var")

# Server function
shinyServer(function(input, output, session) {
    
    # Update dropdowns with contents of vectors
    observe({
        updateSelectInput(session, "assoc",
            choices=c("Choose one"="",associates))
        updateSelectInput(session, "lvl_dtl",
            choices=lvl.dtl$name)
        updateSelectInput(session, "metrics",
            choices=reports$name)
    })
    
    # Bullet list of metric definitions for help text
    output$defs <- renderText({
        isolate(paste(h5(strong("Definitions:")),
                tags$ul(
                    tags$li("Talk Time - Time spent actually talking to customers"),
                    tags$li("Hold Time - Time spent w/ the customer on hold"),
                    tags$li("Followup Time - Time spent making notes or following up after the call"),
                    tags$li("Total Time - The sum of the above")
        )))
    })

    # Return currently selected dates reactively (when Submit is clicked)
    output$dates <- renderText({
        input$submit
        isolate(paste(strong("Report Date:"), input$dates[1],
              "to", input$dates[2]))
    })
    
    # Select function or prod.data variable based on drop-down selections
    rpt.var <- reactive({
        input$submit
        isolate(reports[which(reports$name==input$metrics),"var"])
    })
    lvl.dtl.func <- reactive({
        input$submit
        isolate(lvl.dtl[which(lvl.dtl$name==input$lvl_dtl),"func"])
    })
    
    # Build dataset based on user selections (reactively, on submit)
    assoc.data <- reactive({
        input$submit
        isolate(prod.data %>%
            filter(Associate==input$assoc &
                       as.Date(Date) >= input$dates[1] &
                       as.Date(Date) <= input$dates[2]) %>%
            group_by_(Timeframe=interp(~f(Date), f=as.name(lvl.dtl.func()))) %>%
            summarize_(mean.stats=interp(~weighted.mean(x, w),
                                         x=as.name(rpt.var()),
                                         w=as.name("Calls"))) %>%
            mutate(data.type=input$assoc))
    })
    sum.data <- reactive({
        input$submit
        isolate(prod.data %>%
            filter(as.Date(Date) >= input$dates[1] &
                       as.Date(Date) <= input$dates[2]) %>%
            group_by_(Timeframe=interp(~f(Date), f=as.name(lvl.dtl.func()))) %>%
            summarize_(mean.stats=interp(~weighted.mean(x, w),
                                         x=as.name(rpt.var()),
                                         w=as.name("Calls"))) %>%
            mutate(data.type="Team"))
    })    
    plot.data <- reactive({
        input$submit
        isolate(rbind(assoc.data(), sum.data()))
    })
    
    # Build plot based on user selections (reactively, on submit)
    g <- reactive({
        input$submit
        isolate(ggplot(data=plot.data(), aes(x=Timeframe, y=mean.stats, color=data.type)) +
            geom_line(aes(group=data.type), size=1.5) +
            ggtitle(paste(input$assoc,"-",input$lvl_dtl,input$metrics)) +
            xlab(input$lvl_dtl) +
            ylab(input$metrics) +
            scale_color_manual(values=tableau) +
            theme_bw() +
            guides(col=guide_legend(title="")))
    })
    
    # Return new plot each time Submit is pressed
    output$prod.plot <- renderPlot({
        if (input$submit > submits) {
            submits <<- submits + 1
            if (input$assoc != "" & input$lvl_dtl != "" & input$metrics != "")
                isolate(g())
        }
    })
})