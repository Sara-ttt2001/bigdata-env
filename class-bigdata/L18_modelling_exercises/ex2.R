library(tidyverse)
library(tidymodels)
library(tidyclust)
library(GGally)

metastasis_risk_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L18_modelling_exercises/L18_dataset_metastasis_risk_data.rds"))

metastasis_split = initial_split(metastasis_risk_data)
metastasis_training = training(metastasis_split)
metastasis_testing = testing(metastasis_split)

logistic_regression_model = logistic_reg() %>% 
  set_mode("classification") %>% 
  set_engine("glm")

logreg_recipe <- recipe(metastasis_risk ~ .,
                        data = metastasis_training) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_zv() %>% 
  step_dummy(all_nominal_predictors())

  

log_reg_wf <- workflow() %>% 
  add_recipe(log_reg_recipe) %>% 
  add_model(logistic_regression_model)

log_reg_wf_fit <- fit(
  log_reg_wf,
  metastasis_training
)

logreg_wf_prediction <-
  bind_cols(
    metastasis_testing, log_reg_wf_fit %>% 
      predict(metastasis_testing),
    log_reg_wf_fit %>% 
      predict(metastasis_testing, type = "prob")
  )

logreg_wf_prediction %>% metrics(truth = metastasis_risk, estimate = .pred_class)


