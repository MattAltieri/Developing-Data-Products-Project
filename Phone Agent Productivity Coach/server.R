require(shiny)
require(ggplot2)
require(dplyr)
require(lubridate)
require(lazyeval)

associates <<- as.character(read.csv('./Data/Associate Names.csv')$Names)
prod.data <<- read.csv('./Data/Productivity Data.csv')
prod.data$Total.Call.Time <<- prod.data$Talk.Time + prod.data$Hold.Time +
    prod.data$Followup.Time
prod.data <<- mutate(prod.data, Date=mdy(Date))

submits <<- 0

lvl.dtl <<- as.data.frame(rbind(
        c("Daily","as.character"), #FIX THIS
        c("Weekly","week"),
        c("Monthly","month"),
        c("Quarterly","quarter")),
    stringsAsFactors=F)
names(lvl.dtl) <<- c("name","func")

reports <<- as.data.frame(rbind(
        c("Avg. Talk Time","Talk.Time"),
        c("Avg. Hold Time","Hold.Time"),
        c("Avg. Followup Time","Followup.Time"),
        c("Avg. Total Call Time","Total.Call.Time")),
    stringsAsFactors=F)
names(reports) <<- c("name","var")

shinyServer(function(input, output, session) {
    
    observe({
        updateSelectInput(session, "assoc",
            choices=c("Choose one"="",associates))
        updateSelectInput(session, "lvl_dtl",
            choices=lvl.dtl$name)
        updateSelectInput(session, "rpts",
            choices=reports$name)
    })

    output$assoc <- renderText({
        input$submit
        isolate(paste(strong("Productivity for:"), input$assoc))
    })
    output$dates <- renderText({
        input$submit
        isolate(paste(strong("Report Date:"), input$dates[1],
              "to", input$dates[2]))
    })
    output$lvl_dtl <- renderText({
        input$submit
        isolate(paste(strong("Report Granularity:"), input$lvl_dtl))
    })
    output$rpts <- renderText({
        input$submit
        isolate(paste(strong("Report Type:"), input$rpts))
    })
    
    rpt.var <- reactive({
        reports[which(reports$name==input$rpts),"var"]
    })
    lvl.dtl.func <- reactive({
        lvl.dtl[which(lvl.dtl$name==input$lvl_dtl),"func"]
    })
    
    assoc.data <- reactive({
        prod.data %>%
            filter(Associate==input$assoc &
                       as.Date(Date) >= input$dates[1] &
                       as.Date(Date) <= input$dates[2]) %>%
            group_by_(Timeframe=interp(~f(Date), f=as.name(lvl.dtl.func()))) %>%
            summarize_(mean.stats=interp(~weighted.mean(x, w),
                                         x=as.name(rpt.var()),
                                         w=as.name("Calls"))) %>%
            mutate(data.type=input$assoc)
    })
    sum.data <- reactive({
        prod.data %>%
            filter(as.Date(Date) >= input$dates[1] &
                       as.Date(Date) <= input$dates[2]) %>%
            group_by_(Timeframe=interp(~f(Date), f=as.name(lvl.dtl.func()))) %>%
            summarize_(mean.stats=interp(~weighted.mean(x, w),
                                         x=as.name(rpt.var()),
                                         w=as.name("Calls"))) %>%
            mutate(data.type="Team")
    })
    
    plot.data <- reactive(rbind(assoc.data(), sum.data()))
    
    g <- reactive({
        ggplot(data=plot.data(), aes(x=Timeframe, y=mean.stats, color=data.type)) +
            geom_line(aes(group=data.type))
    })
    
#     output$plot.data.table <- renderTable({
#         if (input$submit > submits) {
#             submits <<- submits + 1
#             if (input$assoc != "" & input$lvl_dtl != "" & input$rpts != "")
#                 isolate(plot.data())
#         }
#     })
    
    output$prod.plot <- renderPlot({
        if (input$submit > submits) {
            submits <<- submits + 1
            if (input$assoc != "" & input$lvl_dtl != "" & input$rpts != "")
                isolate(g())
        }
    })
})