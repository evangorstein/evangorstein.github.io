library(lavaan)
library(MASS)
library(dplyr)
Sigma = matrix(c(1, .6, .6, 1), 2, 2)
set.seed(100)
xy_girls = mvrnorm(n = 10000, c(4, 4), Sigma)
xy_boys = mvrnorm(n = 10000, c(6, 6), Sigma)
xy <- rbind(xy_boys, xy_girls)
colnames(xy) = c("WI", "WF")
df_xy <- as_tibble(xy) %>%
  mutate(S = if_else(row_number() > 10000, 0, 1))


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
newest_sem <- '
  W ~  S
  W =~WI
  WF ~ WI
  
'


fit_new <- sem(newest_sem,
               data = data)

summary(fit_new, fit.measures = TRUE)












