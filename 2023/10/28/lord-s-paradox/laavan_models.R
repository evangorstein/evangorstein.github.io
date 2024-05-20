library(lavaan)
library(MASS)
library(tidyverse)
set.seed(770)
n = 300 # number of students of each sex
mu_girls = c(75,75) # Girls average weight (kg) 
mu_boys = c(85,85) # Boys average weight (kg)
sd = 5 # standard deviation
cor = matrix(c(1,.7,.7,1), 2, 2) #Correlation matrix
Sigma = sd^2*cor
data_girls = mvrnorm(n=n, mu_girls, Sigma)
data_boys = mvrnorm(n=n, mu_boys, Sigma)
data = rbind(data_girls, data_boys)
colnames(data) = c("WI", "WF")
data = as.data.frame(data) %>%
  mutate(S = if_else(row_number() <= n, "girl", "boy"))


pearl <- '
    WI ~  S
    WF ~ S + WI
'
fit_pearl <- sem(pearl, data = df_xy)
summary(fit_pearl, fit.measures = TRUE)
new_sem <- '
  W ~  S
  W =~ WI + WF
  
'
fit_new <- sem(new_sem,
               data = data)

summary(fit_new, fit.measures = TRUE)












