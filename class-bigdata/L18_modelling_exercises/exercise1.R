library(tidyverse)
library(tidymodels)
tidymodels_prefer()
library(GGally)
biodegradation_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L18_modelling_exercises/L18_dataset_biodegradation_data.rds"))

set.seed(345)
data_split = initial_split(biodegradation_data, prop = 0.8)
bio_training = training(data_split)
bio_testing = testing(data_split)

first_model <- linear_reg() %>% 
  set_engine("lm")

bio_recipe <- recipe(
  biodegradation_rate ~.,
  data = biodegradation_data
) %>% 
  step_normalize(all_predictors())

fit_first_model <- first_model %>% 
  fit(PAHs ~., data = bio_training)
tidy(fit_first_model)

predict_first_model = predict(fit_first_model, bio_testing)

predict_first_model <- predict_first_model %>% 
  bind_cols(predict(fit_first_model, bio_testing, type = "pred_int"))

bio_testing %>% 
  bind_cols(
    predict_first_model
  ) %>% 
  ggplot(aes(x=PAHs, y=.pred))+
  geom_point()+
  geom_abline(intercept = 0, slope = 1, colour = "blue")

set.seed(502)
bio_split2 = initial_split(biodegradation_data, prop = 0.8)
bio_training2 = training(bio_split2)
bio_testing2 = testing(bio_split2)

second_model <- rand_forest() %>% 
  set_engine("ranger") %>% 
  set_mode("regression")

second_fit_model <- second_model %>% 
  fit(PAHs ~., data = bio_training2)

second_prediction = predict(second_fit_model, bio_testing2)

second_prediction %>%
  ggplot(aes(x=PAHs, y=.pred))+
  geom_point()+
  geom_abline(intercept = 0, slope = 1, colour = "blue")


