
library(tidyquant)
library(tidyverse)
library(dplyr)

# Getting sector daily returns

# These are SPDR sector ETFs
# SPDR = Standard & Poor’s Depositary Receipt. It is family of exchange-traded funds (ETFs) managed by State Street Global Advisors
sector_tickers <- c(
  "XLY",  # Consumer Discretionary
  "XLP",  # Consumer Staples
  "XLE",  # Energy
  "XLF",  # Financials
  "XLV",  # Health Care
  "XLI",  # Industrials
  "XLB",  # Materials
  "XLK",  # Technology
  "XLU"   # Utilities
)

# daily data on each ETF from 2000 to present
sector_data <- tq_get(sector_tickers,
                      from = "2006-01-01",
                      to   = "2010-12-05",
                      get  = "stock.prices")

# adding sector names to the data
sector_lookup <- tibble(
  symbol = c("XLY","XLP","XLE","XLF","XLV","XLI","XLB","XLK","XLU"),
  sector_name = c(
    "Consumer Discretionary",
    "Consumer Staples",
    "Energy",
    "Financials",
    "Health Care",
    "Industrials",
    "Materials",
    "Technology",
    "Utilities"
  )
)

sector_data <- sector_data %>%
  left_join(sector_lookup, by = "symbol")

sector_data <- sector_data %>%
  arrange(symbol, date) %>%
  group_by(symbol) %>%
  mutate(ret_pct = 100 * (adjusted - lag(adjusted)) / lag(adjusted)) %>%
  mutate(ret_log = 100 * (log(adjusted) - log(lag(adjusted)))) %>%
  ungroup()

sector_weekly_returns <- sector_data %>%
  group_by(symbol, sector_name) %>%
  tq_transmute(
    select = adjusted, 
    mutate_fun = periodReturn,
    period     = "weekly",
    type       = "log", 
    col_rename = "weekly_return_log"
  )

# Sector cumulative returns
cumu_returns <- sector_weekly_returns %>%
  arrange(sector_name, date) %>%
  group_by(sector_name) %>%
  mutate(
    cum_log_return = cumsum(weekly_return_log)
  ) %>%
  ungroup()


# Getting S&P 500 data

sp500 <- tq_get("^GSPC", 
                from = "2000-01-01", 
                to   = "2025-12-05",)

sp500$date <- as.Date(sp500$date, format = "%Y-%m-%d") 

sp500_weekly_returns <- sp500 %>%
  group_by(symbol) %>%
  tq_transmute(
    select = adjusted, 
    mutate_fun = periodReturn,
    period     = "weekly",
    type       = "log",
    col_rename = "weekly_return_log"
  )

# S&P 500 cumulative returns
cumu_returns_sp500 <- sp500_weekly_returns %>%
  arrange(date) %>%
  mutate(
    cum_log_return = cumsum(weekly_return_log)
  ) %>%
  ungroup()
