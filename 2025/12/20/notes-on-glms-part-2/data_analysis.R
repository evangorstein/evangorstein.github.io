library(gamair)
library(dplyr)

data(sole)

sole <- sole %>%
  # create age variables necessary for model
  mutate(
    a = (a.0 + a.1) / 2,
    off = log(a.1 - a.0)
  )

# create a copy of df with centered/scaled variables
sole_c <- sole %>%
  mutate(
    lo = lo-mean(lo),
    la = la - mean(la),
    t = (t - mean(t)) / sd(t)
    )

full_form = formula(
  eggs ~ offset(off) +
    # model for log(S(x)) is cubic in lo, la, and t
    lo + I(lo^2) + I(lo^3) +
    la + I(la^2) + I(la^3) +
    t + I(t^2) + I(t^3) +
    I(lo*la) + I(lo*t) + I(la*t) +
    I(lo*la^2) + I(lo^2*la) +
    I(t*lo^2) + I(t^2*lo) +
    I(t*la^2) + I(t^2*la) +
    I(lo*la*t) +
    # model for delta(x) is quadratic in t
    a + I(a*t) + I(a*t^2)
)

mod <- glm(
  full_form,
  family = quasi(link="log", variance="mu"),
  data = sole_c
)
