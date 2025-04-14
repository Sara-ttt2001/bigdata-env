library(tidyverse)
library(tidymodels)
library(GGally)
blood_pressure_data <- read_tsv("/workspaces/bigdata-env/class-bigdata/L37_tutoring/regression/dataset/mbg_exams_blood_pressure_data.tsv")

ggpairs(blood_pressure_data)

#linear regression model because we have a continuous outcome and predictors

set.seed(502)
bpd_split = initial_split(blood_pressure_data, prop = 0.8)
bpd_training <- training(bpd_split)
bpd_testing <- testing(bpd_split)

lm_model <- linear_reg() %>% 
  set_engine("lm")

lm_recipe <- 
  recipe(blood_pressure_systolic ~ ., 
         data = bpd_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_predictors())

lm_workflow <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(lm_recipe)

lm_wf_fit <- fit(
  lm_workflow,
  bpd_training
)

lm_wf_prediction = lm_wf_fit %>%
  predict(bpd_testing) %>%
  bind_cols(bpd_testing)

lm_wf_prediction %>%
  ggplot(aes(x=blood_pressure_systolic, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)

lm_wf_prediction %>% 
  metrics(truth = blood_pressure_systolic, estimate = .pred)

