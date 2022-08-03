rm(list = ls())
library(dplyr)
library(car)
library(corrplot)


path = "/Users/jerald/Documents/GaTechOMSA/MGT_6203/GroupProject/code/data/"
solar_cycle = read.csv(paste0(path, 'solar_cycle_1.csv'))
wheat_price = read.csv(paste0(path, 'WheatPrices_annual.csv'))
corn_price = read.csv(paste0(path, 'CornPrices_annual.csv'))
radio_flux = read.csv(paste0(path, 'flux_data_extended.csv'))
solar_cycle0 = read.csv(paste0(path, 'solar_cycle.csv'))
wheat_weather = read.csv(paste0(path, 'Wheat_weather_daily.csv')) 
corn_weather = read.csv(paste0(path, 'Corn_weather_daily.csv'))

str(wheat_weather)
str(corn_weather)

# Annual Temperatures 
annual_wheat = wheat_weather %>% 
  mutate(time = ymd(time)) %>% 
  mutate_at(vars(time), funs(year, month, day))%>% 
  group_by(year) %>% 
  summarise_if(is.numeric, mean,na.rm = TRUE) %>%
  select(year, tmax, prcp, snow, wspd) %>%
  data.frame()

annual_corn = corn_weather %>% 
  mutate(time = ymd(time)) %>% 
  mutate_at(vars(time), funs(year, month, day))%>% 
  group_by(year) %>% 
  summarise_if(is.numeric, mean,na.rm = TRUE) %>%
  select(year, tmax, prcp, snow, wspd) %>%
  data.frame()

# annual Sun spot numbers 
solar_cycle = solar_cycle %>% 
  mutate(date = ymd(Date)) %>% 
  mutate_at(vars(date), funs(year, month, day))

solar_annualized_mean = solar_cycle %>% 
  group_by(year) %>% 
  summarise(ssn_total = sum(ssn), avg_rf = mean(f10.7)) %>%
  select(year, ssn_total) %>% 
  data.frame()

# radio flux data cleaning
radio_flux$Date = ymd(radio_flux$time..yyyy.MM.dd.)
flux_df = radio_flux %>% 
  mutate(date = ymd(Date)) %>% 
  mutate_at(vars(date), funs(year, month, day))  %>% 
  group_by(year) %>% 
  summarise_all(mean) %>% 
  subset(select = -c(Date, date, month, day, time..yyyy.MM.dd.)) %>%
  data.frame() %>%
  select(year, absolute_f30)


########### Wheat Model data frame
wheat_price$year = wheat_price$Year

wheat_df = merge(wheat_price, solar_annualized_mean, by = 'year') %>%
            subset(select = -c(Year, AvgClose, Open, High,  Low, PercentChange))
names(wheat_df)[names(wheat_df) == 'Close'] = 'Wheat_price'
#wheat_df = merge(wheat_df, flux_df, by = 'year')
wheat_df = merge(wheat_df, annual_wheat, by = 'year')
head(wheat_df)
plot(wheat_df)
corrplot(cor(wheat_df[,-1]))

########### Corn Model data frame
corn_price$year = corn_price$Year
corn_df = merge(corn_price, solar_annualized_mean, by = 'year') %>%
  subset(select = -c(Year, AvgClose, Open, High,  Low, PercentChange))
names(corn_df)[names(corn_df) == 'Close'] = 'Corn_price'
#corn_df = merge(corn_df, flux_df, by = 'year')
corn_df = merge(corn_df, annual_corn, by = 'year')
head(corn_df)
plot(corn_df)


########### Natrual Gas Model data frame
wheat_model = lm('Wheat_price ~.', data = wheat_df[,-1])
corn_model = lm('Corn_price ~.', data = corn_df[,-1])

summary(wheat_model)
summary(corn_model)

hist(resid(wheat_model))
hist(resid(corn_model))


vif(wheat_model) # extremly high vif 
vif(corn_model) # extremly high vif in ssn_total and absolute f30 



