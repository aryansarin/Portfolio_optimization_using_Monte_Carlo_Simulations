library(quantmod)
library(PerformanceAnalytics)
library(shiny)
library(ggplot2)
library(dplyr)
library(bslib)
library(plotly)
library(shinydashboard)
library(shinyWidgets)

ui <- fluidPage(
  theme = bs_theme(
    bg = "#0e1117",
    fg = "#ffffff",
    primary = "#00c6ff",
    secondary = "#1f2937",
    base_font = font_google("Poppins")
  ),
  
  tags$head(
    tags$style(HTML("
      .card {
        background-color: #161b22;
        border-radius: 15px;
        padding: 15px;
        margin-bottom: 20px;
        box-shadow: 0px 0px 10px rgba(0,0,0,0.5);
      }
      .btn {
        background-color: #00c6ff;
        color: black;
        font-weight: bold;
        border-radius: 10px;
      }
      h2, h3 { color: #00c6ff; }
    "))
  ),
  
  titlePanel("Portfolio Optimization Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      div(class="card",
          
          selectizeInput("stocks","Select Stocks",
                         choices = c("RELIANCE.NS","TCS.NS","INFY.NS","HDFCBANK.NS","ICICIBANK.NS"),
                         multiple = TRUE,
                         selected = c("RELIANCE.NS","TCS.NS")),
          
          sliderInput("simulations","Number of Portfolios",5000,50000,10000,5000),
          sliderInput("rf","Risk-Free Rate",0,0.1,0.06,0.005),
          sliderInput("conf","VaR Confidence",0.90,0.99,0.95,0.01),
          
          actionButton("run","Run Simulation")
      )
    ),
    
    mainPanel(
      
      fluidRow(
        column(3, valueBoxOutput("returnBox")),
        column(3, valueBoxOutput("riskBox")),
        column(3, valueBoxOutput("sharpeBox")),
        column(3, valueBoxOutput("varBox"))
      ),
      
      fluidRow(
        column(6, div(class="card", h3("Efficient Frontier"), plotlyOutput("frontierPlot"))),
        column(6, div(class="card", h3("Backtest"), plotlyOutput("backtestPlot")))
      ),
      
      fluidRow(
        column(6, div(class="card", h3("Best Portfolio"), tableOutput("bestPortfolio"))),
        column(6, div(class="card", h3("Risk Metrics"), tableOutput("riskMetrics")))
      ),
      
      fluidRow(
        column(12, div(class="card", h3("Insights"), textOutput("insights")))
      )
    )
  )
)

server <- function(input, output){
  
  observeEvent(input$run, {
    
    assets <- input$stocks
    if (is.null(assets) || length(assets) < 2) return()
    
    getSymbols(assets, from='2020-01-01', src='yahoo', auto.assign = TRUE)
    
    prices <- do.call(merge, lapply(assets, function(x) Ad(get(x))))
    colnames(prices) <- assets
    
    returns <- na.omit(Return.calculate(prices, method='log'))
    
    dates <- index(returns)
    split_date <- as.Date("2023-01-01")
    
    train_returns <- returns[dates < split_date]
    test_returns  <- returns[dates >= split_date]
    
    mean_returns <- colMeans(train_returns)
    cov_matrix <- cov(train_returns)
    
    num_portfolios <- input$simulations
    num_assets <- length(assets)
    
    results <- data.frame()
    weights_list <- list()
    
    while(nrow(results) < num_portfolios){
      
      weights <- runif(num_assets)
      weights <- weights / sum(weights)
      names(weights) <- assets
      
      if(any(weights > 0.6) || any(weights < 0.05)) next
      
      port_return <- sum(weights * mean_returns) * 252
      port_vol <- sqrt(t(weights) %*% (cov_matrix * 252) %*% weights)
      
      sharpe <- (port_return - input$rf) / port_vol
      
      port_series <- train_returns %*% weights
      
      VaR <- quantile(port_series, 1 - input$conf)
      CVaR <- mean(port_series[port_series < VaR])
      
      results <- rbind(results, data.frame(Return=port_return,Volatility=port_vol,Sharpe=sharpe,VaR=VaR,CVaR=CVaR))
      weights_list[[nrow(results)]] <- weights
    }
    
    max_sharpe_idx <- which.max(results$Sharpe)
    best_weights <- weights_list[[max_sharpe_idx]]
    
    output$frontierPlot <- renderPlotly({
      p <- ggplot(results, aes(Volatility, Return, color = Sharpe)) +
        geom_point(alpha = 0.6) +
        theme_minimal() +
        theme(
          plot.background = element_rect(fill = "#0e1117", color = NA),
          panel.background = element_rect(fill = "#0e1117", color = NA),
          panel.grid = element_line(color = "#2a2e39"),
          text = element_text(color = "white"),
          axis.text = element_text(color = "white"),
          axis.title = element_text(color = "white"),
          legend.background = element_rect(fill = "#0e1117"),
          legend.text = element_text(color = "white"),
          legend.title = element_text(color = "white")
        )
      ggplotly(p)
    })
    
    output$bestPortfolio <- renderTable({
      data.frame(Asset = assets, Weight = round(best_weights,3))
    })
    
    output$riskMetrics <- renderTable({
      results[max_sharpe_idx,]
    })
    
    output$backtestPlot <- renderPlotly({
      
      port_returns <- test_returns %*% best_weights
      cumulative <- cumprod(1 + port_returns)
      
      df <- data.frame(
        Date = index(test_returns),
        Value = as.numeric(cumulative)
      )
      
      p <- ggplot(df, aes(Date, Value)) +
        geom_line(color = "#00c6ff") +
        labs(title = "Portfolio Backtest",
             x = "Date",
             y = "Growth of ₹1") +
        theme_minimal() +
        theme(
          plot.background = element_rect(fill = "#0e1117", color = NA),
          panel.background = element_rect(fill = "#0e1117", color = NA),
          panel.grid = element_line(color = "#2a2e39"),
          text = element_text(color = "white"),
          axis.text = element_text(color = "white"),
          axis.title = element_text(color = "white")
        )
      
      ggplotly(p)
    })
    
    output$returnBox <- renderValueBox({
      valueBox(round(results$Return[max_sharpe_idx],3),"Return",icon=icon("chart-line"))
    })
    
    output$riskBox <- renderValueBox({
      valueBox(round(results$Volatility[max_sharpe_idx],3),"Volatility",icon=icon("exclamation-triangle"))
    })
    
    output$sharpeBox <- renderValueBox({
      valueBox(round(results$Sharpe[max_sharpe_idx],3),"Sharpe",icon=icon("balance-scale"))
    })
    
    output$varBox <- renderValueBox({
      valueBox(
        paste0(round(results$VaR[max_sharpe_idx]*100,2), "%"),
        paste0("Daily VaR (", input$conf*100, "%)"),
        icon = icon("skull-crossbones")
      )
    })
    
    output$insights <- renderText({
      
      ret <- results$Return[max_sharpe_idx]
      vol <- results$Volatility[max_sharpe_idx]
      sharpe <- results$Sharpe[max_sharpe_idx]
      var <- results$VaR[max_sharpe_idx]
      weights <- best_weights
      
      insight <- ""
      
      if (sharpe < 0.5) {
        insight <- paste0(insight, 
                          "The portfolio has a low Sharpe Ratio (", round(sharpe,2), 
                          "), indicating poor risk-adjusted returns. ")
      } else if (sharpe < 1) {
        insight <- paste0(insight, 
                          "The portfolio shows moderate risk-adjusted performance. ")
      } else {
        insight <- paste0(insight, 
                          "The portfolio demonstrates strong risk-adjusted performance. ")
      }
      
      if (vol > 0.25 & sharpe < 0.5) {
        insight <- paste0(insight,
                          "High volatility (", round(vol,2), 
                          ") is not being compensated with sufficient returns. ")
      }
      
      if (max(weights) > 0.5) {
        dominant_asset <- names(which.max(weights))
        insight <- paste0(insight,
                          "The portfolio is highly concentrated in ", dominant_asset,
                          ", reducing diversification benefits. ")
      } else {
        insight <- paste0(insight,
                          "The portfolio maintains reasonable diversification across assets. ")
      }
      
      var_pct <- round(var * 100, 2)
      
      insight <- paste0(insight,
                        "At a ", input$conf*100, "% confidence level, the portfolio may lose approximately ",
                        var_pct, "% in a single day under adverse conditions. ",
                        "This backtest is performed on out-of-sample data.")
      
      insight
    })
  })
}

shinyApp(ui = ui, server = server)