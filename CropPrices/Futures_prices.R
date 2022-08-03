library(lubridate)
library(xts)
path = 'MGT_6203/GroupProject/code/data'

######## Load in the Price data----------------------------------------------------
tickers <- c("^GSPC","^SPGSCI","^DJI", "^IXIC","^VIX","TYX", "TNX")
data = new.env()

library(quantmod)

getSymbols(tickers, 
           src = 'yahoo', 
           from  = '1990-01-01', 
           env = data)
# RENAME THE COLUMNS TO TO EXCLUDE THE TICKER NAME 
for (i  in tickers){
colnames(data[[i]]) = c("Open", "High", "Low", "Close", "Volume", "Adjusted")}
head(data$GSPC)

######## Load in the Solar data----------------------------------------------------

solar_cycle = read.csv(paste0(path, '/solar_cycle.csv'))
solar_cycle$time.tag = ymd(solar_cycle$time.tag)
# Monthly solar sunspots
solar_cycle_ts = xts(solar_cycle[,-1], order.by = solar_cycle[,1]) 
tformat(solar_cycle_ts) = "%Y-%m"
tail(solar_cycle_ts)

###### Get Monthly Returns
market_month_ret = monthlyReturn(data$GSPC)
tail(market_month_ret)

# Merge data 
dte_seq = seq(as.Date("1990/01/01"), as.Date("2022/06/01"), 'months' )
index(market_month_ret) = dte_seq
df = merge.xts(market_month_ret[dte_seq],solar_cycle_ts[dte_seq,])
head(df)


plot(solar_cycle_ts[dte_seq, ])


ppi_commodity_index = read.csv(paste0(path,'/Commodity_PPI_index.csv'))
ppi_commodity_index$DATE = ymd(ppi_commodity_index$DATE)
ppi_commodity_index = xts(ppi_commodity_index[,2], order.by = ppi_commodity_index$DATE)
min.date = min(index(ppi_commodity_index))
max.date = max(index(ppi_commodity_index))


df2 = merge.xts(ppi_commodity_index,solar_cycle_ts[seq(min.date, max.date, 'months')])

m1 = lm('monthly.returns~ssn', data = df)
m2 = lm('ppi_commodity_index~.', data = df2)
summary(m1)
summary(m2)



library(tseries)
garch_model = garch(df2$ssn, order = c(1,1))
summary(garch_model)
par(mfcol = c(1,1))
plot(garch_model)



library('car')


