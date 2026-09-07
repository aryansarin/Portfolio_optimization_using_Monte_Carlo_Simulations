# Portfolio Optimization Dashboard using Monte CarloSimulations
An interactive web application built with R Shiny for portfolio optimization using Monte Carlo simulation. The dashboard is tailored for the Indian stock market (NSE) and incorporates advanced risk-adjusted performance metrics, portfolio constraints, and out-of-sample backtesting to help investors design and evaluate robust asset allocations.

# Key Features
1. Monte Carlo Simulation: Generates thousands of random portfolio weight combinations (ranging from 5,000 to 50,000 portfolios) to map out the Efficient Frontier and identify optimal asset weightings.

2. Indian Market Integration: Pre-configured with major National Stock Exchange (NSE) tickers such as RELIANCE.NS, TCS.NS, INFY.NS, HDFCBANK.NS, and ICICIBANK.NS.

3. Risk-Adjusted Metrics: Evaluates portfolios using the Sharpe Ratio, Value at Risk (VaR), and Conditional Value at Risk (CVaR) at customizable confidence levels (e.g., 90%, 95%, 99%).

4. Out-of-Sample Backtesting: Employs a train-test split methodology to validate portfolio performance on unseen data, effectively eliminating look-ahead bias.

5. Interactive Controls & Visuals: Dynamic UI widgets for adjusting the risk-free rate, confidence intervals, and portfolio sampling scale, paired with automated KPI insights and performance cards.

# Dashboard Layout & Controls
1. **Select Stocks:** Input box to specify target NSE ticker symbols (e.g., RELIANCE.NS, TCS.NS, INFY.NS, HDFCBANK.NS, ICICIBANK.NS).
2.  **Number of Portfolios:** Interactive slider to set simulation intensity from 5,000 up to 50,000 iterations.
3.  Risk-free rate: Adjustable slider (default set to 6.0% / 0.06) to compute excess returns and Sharpe ratios.
4.  **VaR Confidence:** Configurable confidence slider (0.90 to 0.99) for downside risk estimation.
5.  **Efficient Frontier:** Visual plot highlighting the risk-return trade-off across simulated portfolios, marking the Maximum Sharpe Ratio and Minimum Variance portfolios.
6.  **Backtest Panel:** Out-of-sample performance validation tracking cumulative returns against a benchmark or equal-weight baseline.
7.  **Best Portfolio and Risk Metrics:** Summary cards detailing optimal asset allocations, expected returns, volatility, VaR, and CVaR.

# Tech Stack
Language: R

Framework: Shiny

Finance & Quant Libraries: quantmod, PerformanceAnalytics, PortfolioAnalytics (or custom optimization logic)

Visualizations: ggplot2, plotly / Shiny reactive plotting outputs

# Getting Started
## Prerequisites
Ensure you have R and RStudio installed on your machine. You will need to install the required packages to run the Shiny application:
install.packages(c("shiny", "quantmod", "PerformanceAnalytics", "ggplot2", "DT"))
## Installation & Execution
1. Clone the repository:
git clone https://github.com/your-username/portfolio-optimization-shiny.git
cd portfolio-optimization-shiny

2. Open the project directory in RStudio and open app.R.

3. Run the application by clicking Run App in RStudio or executing the following command in the R console:
shiny::runApp("app.R")

# Usage Guide
Enter your desired NSE stock tickers separated by commas in the Select Stocks field.

Fine-tune your simulation parameters, including the Number of Portfolios, current Risk-Free Rate, and VaR Confidence level.

Click Run Simulation to compute the efficient frontier and generate backtest results.

Review the optimal asset weights and risk analytics displayed in the output cards.
