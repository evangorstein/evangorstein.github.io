### Regression to the mean
library(MASS)

Sigma = matrix(c(1,.8,.8,1), 2, 2)
set.seed(100)
xy = mvrnorm(n=10000, c(5,5), Sigma)
par(pty="s")
plot(xy, xaxt ="n", yaxt = "n", xlab = "x", ylab = "y", main = "Some regression")
axis(side = 1, at = c(2,4,6.25))
axis(side = 2, at = c(2,4,6))


lin_mod = lm(xy[,2]~xy[,1])
abline(lin_mod, col = "red", lwd = 2)
abline(v=6.25, col="blue", lwd = 2)
abline(h=6.25, col = "blue", lwd = 2)
abline(h = 6, col = "blue", lwd = 2)
abline(0,1, col = "yellow", lwd = 2)
## E[ Y | X=7.5] = .8*6.25 + .2*5 = 6


Sigma = matrix(c(1,.6,.6,1), 2, 2)
set.seed(100)
xy = mvrnorm(n=10000, c(5,5), Sigma)
par(pty="s")
plot(xy, xaxt ="n", yaxt = "n", xlab = "x", ylab = "y", 
     main = "More regression")
axis(side = 1, at = c(2,4,6.25))
axis(side = 2, at = c(2,4,5.75))


lin_mod = lm(xy[,2]~xy[,1])
abline(lin_mod, col = "red", lwd = 2)
abline(v=6.25, col="blue", lwd = 2)
abline(h = 6.25, col = "blue", lwd = 2)
abline(h=5.75, col = "blue", lwd = 2)
abline(0,1, col = "yellow", lwd = 2)
## E[ Y | X=7.5] = .6*6.25 + .4*5 = 5.75

Sigma = matrix(c(1,.6,.6,1), 2, 2)
xy_girls = mvrnorm(n=1000, c(4,4), Sigma)
xy_boys = mvrnorm(n=1000, c(6,6), Sigma)
par(pty="s")
plot(xy_girls, xlim = c(0, 8), ylim = c(0, 8), col = "blue", 
     xlab = "Pre-semester weight", ylab = c("Post-semester weight"))
points(xy_boys, col = "green")
legend(.5, 7.5, legend = c("girls", "boys"), 
       col = c("blue", "green"), pch = 1)

#Let's consider a boy and girl who both weigh 4.5 
lm_girls = lm(xy_girls[,2] ~ xy_girls[,1])
lm_boys = lm(xy_boys[,2] ~ xy_boys[,1])
abline(lm_girls, col = "blue", lwd = 2)
abline(lm_boys, col = "green", lwd = 2)
abline(0,1, col = "yellow", lwd = 2)



Sigma = matrix(c(1,.5,.5,1), 2, 2)
set.seed(100)
xy = mvrnorm(n=10000, c(5,5), Sigma)
par(pty="s")
plot(xy)
abline(0,1, col = "green", lwd = 3)
abline(lm(xy[,1]~xy[,2]), col = "red", lwd = 3)
prcomp(xy)$rotation[,1]
lm()







