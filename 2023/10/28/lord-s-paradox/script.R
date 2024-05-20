#Let’s see if we can simulate Lord’s data. We’ll need two distinct bivariate normal distributions, one for the boys and one for the girls. 
#In particular, let’s suppose \[ (W_I,W_F) \mid S \sim N((\mu_S, \mu_S), 25\begin{bmatrix} 1 & 0.7 \\ 0.7 & 1 \end{bmatrix}), \] 
# where \(\mu_1 = 85\)kg (\(\mu_0 = 75\)kg) is the average weight of male (female) students both before and after the school year. 
# We simulate a school with 300 boys and 300 girls as follows:
  
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

#Now let’s run the regression that Statistician 2 did and extract the coefficients

ancov <- lm(WF ~ WI + S, data = data)
coef = coef(ancov)
coef_boys = coef[c(1,2)]
coef_girls = c(coef[1] + coef[3], coef[2])
#And now let’s plot:
  
plot(data$WI, 
     data$WF,  
     col = if_else(data$S == "girl", "orange", "blue"), 
     xlab = "Pre-semester weight",  
     ylab = "Post-semester weight", 
     asp = 1)
abline(coef = coef_girls, col = "orange", lwd = 2, lty = "dashed")
abline(coef = coef_boys, col = "blue", lwd = 2, lty = "dashed")
abline(0,1, col = "black", lwd = 2)
legend("topleft", legend = c("girls", "boys"), 
       col = c("orange", "blue"), pch = 1)





