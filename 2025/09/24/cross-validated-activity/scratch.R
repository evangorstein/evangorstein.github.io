# SQL Query1: 
# SELECT
# CONVERT(date, CreationDate) AS Date,
# COUNT(*) AS PostCount
# FROM PostsWithDeleted
# WHERE
# PostTypeId = 1
# GROUP BY
# CONVERT(date, CreationDate)
# ORDER BY
# CONVERT(date, CreationDate);


# SQL Query 2:
# SELECT
# DATEADD(MONTH, DATEDIFF(MONTH, 0, A.CreationDate), 0) AS Created,
# C.TagName AS Tag,
# COUNT(*) AS MonthlyCount
# FROM
# (SELECT * FROM PostsWithDeleted WHERE PostTypeId = 1) AS A
# LEFT JOIN PostTags AS B
# ON A.Id = B.PostId
# LEFT JOIN
# (
#   SELECT TOP 100 * FROM Tags
#   WHERE TagName IS NOT NULL
#   ORDER BY Count DESC
# ) AS C ON B.TagId = C.Id
# GROUP BY
# -- Repeat the full expressions from the SELECT statement here
# DATEADD(MONTH, DATEDIFF(MONTH, 0, A.CreationDate), 0),
# C.TagName
# ORDER BY
# -- You CAN use the alias in ORDER BY because it runs after SELECT
# Created DESC

library(segmented)
library(changepoint)
library(mcp)
library(tidyverse)
library(directlabels)


options(mc.cores = 6)  # Speed up sampling
theme_set(theme_minimal())
theme_update(panel.grid.minor = element_blank())

# Exploring aggregate time series for different subjects ------------------

# read all csvs
csvs <- list.files("data/", pattern = "^.*\\.csv$", full.names = TRUE)
question_counts <- read_csv(csvs, col_types = "Ti", id = "subject") 

# formatting
question_counts <- question_counts %>%
  mutate(
    subject = str_remove_all(subject, "(data//|\\.csv)"),
    Date = date(Date)
  ) %>%
  rename(
    date = Date,
    post_count = PostCount
    ) %>%
  arrange(date)

# take a look at what subjects we have data for
question_counts %>% 
  group_by(subject) %>%
  summarise(n_days = n(), avg_count = mean(post_count)) %>%
  arrange(desc(avg_count))


# aggregate by month
by_month <- question_counts %>%
  mutate(month = floor_date(date, "month")) %>%
  summarise(
    post_count = sum(post_count),
    .by = c(subject, month)
    )

# add baseline
ref_date <- ymd("2015-01-01")
ref_date_fmt = format(ref_date, "%b %Y")
# filter bioinformatics because it's newer and wasn't around in Jan 2017
by_month_exc_bio <- by_month %>% 
  filter(subject != "Bioinformatics") %>% 
  group_by(subject) %>%
  mutate(baseline = post_count[month == ref_date]) %>%
  ungroup() %>%
  mutate(index = post_count/baseline * 100) 

# plot time series 
chat_gpt = ymd("2022-12-01")
up_to = ymd("2025-01-01")
by_month_exc_bio %>%
  filter(subject %in% c(
    "Mathematics",
    "CrossValidated",
    "StackOverflow",
    "MathOverflow",
    "Physics",
    "TeX"
  )) %>%
  filter(month >= ref_date, month < up_to) %>%
  ggplot(aes(month, index, group = subject, color = subject)) +
  geom_line() +
  geom_vline(xintercept = chat_gpt, linetype = "dashed") +
  geom_dl(aes(label = subject), method = "last.points", cex = 0.8) +
  annotate("text", x = chat_gpt, y = 125, hjust = -0.1, label = "Chat GPT") +
  scale_x_date(
    name = NULL, 
    date_breaks = "1 year", 
    date_labels = "%Y"
    ) +
  scale_color_discrete(guide="none") +
  coord_cartesian(clip = 'off') +
  labs(
    y = str_glue("Index ({ref_date_fmt} = 100)"),
    title = "Number of questions posted on Stack Exchange"
  ) +
  theme(plot.margin = margin(0.1, 2.6, 0.1, 0.1, "cm"))





# Change point modeling ---------------------------------------------------

## Warm-up: modeling 2015 through 2019 stack overflow data ----------------

start_date = ymd("2015-01-01")
end_date = ymd("2020-01-01")
so_by_month <- by_month %>%
  filter(subject=="StackOverflow") %>%
  filter(month >= start_date, month < end_date) %>%
  # add a numeric time variable representing number of months passed for modeling
  mutate(time = time_length(interval(min(month), month), "month"))

ggplot(so_by_month, aes(month, post_count)) +
  geom_line()

mod1 = list(
  post_count ~ 1,   
  ~ 0 + time
)
prior1 = list(
  int_1 = "dunif(200000, 300000)"
  # cp_1, the changepoint, not specified, will default to dunif(MINX, MAXX),
  #time_2, i.e. the slope after the changepoint, not specified, will use default 
  #sigma_1 not specified, will use default
)


# Look at prior predictive
empty_manual = mcp(mod1, prior = prior1, sample = FALSE)
empty_default = mcp(mod1, sample = FALSE)
cbind(manual = empty_manual$prior, default = empty_default$prior)

set.seed(770)
fit_pp_manual = mcp(mod1, so_by_month, prior1, sample = "prior")
fit_pp_default = mcp(mod1, so_by_month, sample = "prior")
plot(fit_pp_manual, lines = 100) 
plot(fit_pp_default, lines = 100)


# Actually fit model, i.e. sample from posterior
fit_manual = mcp(mod1, so_by_month, prior1)
fit_default = mcp(mod1, so_by_month)
plot(fit_manual, lines = 500, geom_data="line") + 
  scale_x_continuous(
    breaks = seq(0, max(so_by_month$time), by = 6),  # every 6 months
    labels = function(x) format(start_date %m+% months(x), "%b %y")
  ) 
plot(fit_default, lines = 500, geom_data="line") +
  scale_x_continuous(
    breaks = seq(0, max(so_by_month$time), by = 6),  # every 6 months
    labels = function(x) format(start_date %m+% months(x), "%b %y")
  ) 


## Up complexity: model through the end of 2022, right before ChatGPT drops  ----      

end_date = ymd("2022-11-01")
so_by_month_more <- by_month %>%
  filter(subject=="StackOverflow") %>%
  filter(month >= start_date, month <= end_date) %>%
  # add a numeric time variable representing number of months passed for modeling
  mutate(time = time_length(interval(min(month), month), "month"))

ggplot(so_by_month_more, aes(month, post_count)) +
  geom_line()

mod_more = list( # allow for 4 change points, but insist that final segment is flat. You can try without imposing this, and you run into interesting identifiability issues
  post_count ~ 1,   
  ~ 0 + time,
  ~ 0 + time,
  ~ 0 + time,
  ~ 0 
)
prior_more = list(
  int_1 = "dunif(200000, 300000)"
  # cp_1, cp_2, cp_3, cp_4 not specified
  #time_2, time_3, time_4 not specified 
  #sigma_1 not specified
)

# Look at prior predictive
empty_manual_more = mcp(mod_more, prior = prior_more, sample = FALSE)
empty_default_more = mcp(mod_more, sample = FALSE)
cbind(manual = empty_manual_more$prior, default = empty_default_more$prior)

set.seed(770)
fit_pp_manual_more = mcp(mod_more, so_by_month_more, prior_more, sample = "prior")
fit_pp_default_more = mcp(mod_more, so_by_month_more, sample = "prior")
plot(fit_pp_manual_more, lines = 100) 
plot(fit_pp_default_more, lines = 100)

# Actually fit model, i.e. sample from posterior
fit_manual_more = mcp(mod_more, so_by_month_more, prior_more, chains = 5, adapt = 10000)
fit_manual_more
plot_pars(fit_manual_more, regex_pars = "cp_")
plot_pars(fit_manual_more, regex_pars = "time_")
plot_pars(fit_manual_more, pars = c("cp_2", "time_3"), type="hex")
plot(fit_manual_more, lines = 20, geom_data="line") + 
  scale_x_continuous(
    breaks = seq(0, max(so_by_month_more$time), by = 6),  # every 6 months
    labels = function(x) format(start_date %m+% months(x), "%b %y")
  ) 

# Let's check whether 3 change points are enough
mod_more_red = list( # allow for only 3 change points
  post_count ~ 1,   
  ~ 0 + time,
  ~ 0 + time,
  ~ 0 + time
)
fit_manual_more_red = mcp(mod_more_red, so_by_month_more, prior_more, chains = 5, adapt = 10000)
fit_manual_more_red
plot_pars(fit_manual_more_red, regex_pars = "cp_")
plot_pars(fit_manual_more_red, regex_pars = "time_")
plot_pars(fit_manual_more_red, pars = c("cp_2", "time_3"), type="hex")
plot(fit_manual_more_red, lines = 20, geom_data="line") + 
  scale_x_continuous(
    breaks = seq(0, max(so_by_month_more$time), by = 6),  # every 12 months
    labels = function(x) format(start_date %m+% months(x), "%b %y")
  ) 

# Compare
fit_manual_more_red$loo = loo(fit_manual_more_red) 
fit_manual_more$loo = loo(fit_manual_more) 
loo::loo_compare(fit_manual_more$loo, fit_manual_more_red$loo) 
# full model is preferred

# what does the segmented package give you?
fit_lm = lm(post_count ~ 1 + time, data = so_by_month_more)

# full
fit_segmented_full = segmented(fit_lm, seg.Z = ~time, npsi = 4)
summary(fit_segmented_full)
old_par <- par(no.readonly = TRUE)
par(mar = c(3.1, 4.1, 4.1, 2.1))  
plot(so_by_month_more$time, so_by_month_more$post_count, 
     xaxt = "n", ylab = "Posts", type="l")
ticks <- seq(0, max(so_by_month_more$time), by = 3)
labels <- format(start_date %m+% months(ticks), "%b %y")
axis(1, at = ticks, labels = labels)
plot(fit_segmented_full, add=TRUE)
lines.segmented(fit_segmented_full)
points.segmented(fit_segmented_full)

#reduced 
fit_segmented_red = segmented(fit_lm, seg.Z = ~time, npsi = 3)
summary(fit_segmented_red)
plot(so_by_month_more$time, so_by_month_more$post_count, 
     xaxt = "n", ylab = "Posts", type="l")
ticks <- seq(0, max(so_by_month_more$time), by = 3)
labels <- format(start_date %m+% months(ticks), "%b %y")
axis(1, at = ticks, labels = labels)
plot(fit_segmented_red, add=TRUE)
lines.segmented(fit_segmented_red)
points.segmented(fit_segmented_red)

# compare full to reduced
BIC(fit_segmented_full); BIC(fit_segmented_red) 
# full model is preferred!

# return to original graphic parameters
par(old_par)

# Run changepoint analysis with changepoint library
cp_meanvar <- cpt.meanvar(so_by_month_more$post_count, method = "PELT")
so_by_month_more$month[cpts(cp_meanvar)] 
plot(cp_meanvar) # Two downward change points at Nov 2017 and June 2021

## Do the same analyses for math, cross validated, physics, and TeX --------

# Exploring time series of different CrossValidated tags ------------------
cv_tags <- read_csv("data/CrossValidatedTags/CV_tags.csv", show_col_types = FALSE) %>%
  rename(
    month = Created,
    tag = Tag,
    count = Count 
  ) %>%
  mutate(month = date(month))

cv_tags %>%
  drop_na(tag) %>% # rows with tag=NA contain the aggregate count for all other tags for the given month
  filter(tag %in% c(
    #"regression",
    #"machine-learning", 
    #"r",
    "convolutional-neural-network",
    "causality",
    "svm"
    #"deep-learning",
    #"neural-networks",
    #"python"
  )) %>%
  ggplot(aes(month, count, group = tag, color = tag)) +
  geom_line() +
  geom_vline(xintercept = chat_gpt, linetype = "dashed") +
  geom_dl(aes(label = tag), method = list("last.points","bumpup"), cex = 0.8) +
  annotate("text", x = chat_gpt, y = 50, hjust = -0.1, label = "Chat GPT") +
  scale_x_date(
    name = NULL, 
    date_breaks = "1 year", 
    date_labels = "%Y"
  ) +
  scale_color_discrete(guide="none") +
  coord_cartesian(clip = 'off') +
  labs(
    y = "Posts",
    title = "Monthly posts on CrossValidated by subject over time"
  ) +
  theme(plot.margin = margin(0.1, 2.6, 0.1, 0.1, "cm"))
  







