theta=7
alpha1=.025
alpha2=.025
n=100
simul=1000

lb <- numeric(simul)
ub <- numeric(simul)
est <- numeric(simul)
set.seed(42070)

for (i in 1:simul) {
  data <- rexp(n) + 7
  t <- min(data)
  est[i] <- t-1/n
  lb[i] <- t + log(alpha2)/n
  ub[i] <- t + log(1-alpha1)/n
}

sum(7>lb & 7<ub)


library(plotrix)


mycolor <- function(endpoints, mn) {
  if (mn < endpoints[1]) 
    "Red" # if the mean is below the left endpoint of the confidence interval
  else if (mn > endpoints[2]) 
    "Orange" # if the mean is above the right endpoint of the confidence interval
  else 
    "Black" # if the mean lies between the endpoints
}

ci<- cbind(lb, ub)
z <- apply(ci,1,mycolor,7)

plotCI(x=est, y=1:simul, ui=ub, li=lb, err="x", gap=T, col=z)
abline(v=7)



