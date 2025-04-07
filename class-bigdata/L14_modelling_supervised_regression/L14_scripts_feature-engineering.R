

library(tidyverse)
library(tidymodels)
tidymodels_prefer()


#######################
## center and scale ###
#######################


rf_model_reg <- rand_forest() %>% 
  set_mode("regression") %>% 
  set_engine("ranger")

## creating a recipe
enzyme_recipe <- 
  recipe(product ~ temperature + substrateA + substrateB + enzymeA + enzymeB + enzymeC + eA_rate + eB_rate + eC_rate, 
         data = enzyme_training) %>% 
  step_center(all_predictors()) %>% ## centre all predictors 
  step_scale(all_predictors()) ## scale all predictors
#we can use step_normalize()

rf_workflow <- workflow() %>% 
  add_model(rf_model_reg) %>% 
  add_recipe(enzyme_recipe)


rf_wf_enzyme_fit <- fit(
  rf_workflow,
  enzyme_training
)

enzyme_rf_wf_prediction = rf_wf_enzyme_fit %>%
  predict(enzyme_testing) %>%
  bind_cols(enzyme_testing)

enzyme_rf_wf_prediction %>%
  ggplot(aes(x=product, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)

enzyme_rf_wf_prediction %>% 
  metrics(truth = product, estimate = .pred)

## if we compare with the previous model

enzyme_rf_prediction  %>%
  metrics(truth = product, estimate = .pred)

## we can see it has helped, just a little in terms of RSQ (increased) and RMSE (reduced)

######Here’s what’s happening:
#1. The low-range predictions (small product values) are even tighter.

#Very little spread around the red diagonal line at low product values.
#Before scaling, there was a little "fan" shape spreading out from 0 — now it's much sharper!
#➔ Conclusion:
#✅ Scaling helped standardize the range of the input features, making Random Forest training more stable, especially for smaller targets.

#2. The overall shape is very similar at mid-range.

#Around 1000–2000, points are still hugging the diagonal nicely.
#This means scaling didn't hurt the model's ability to capture the main trend. Good sign!
#3. High product values:

#There's still some underestimation for large product values (over 2000–3000+).
#Scaling doesn’t completely solve that because Random Forest tends to struggle with extrapolation (it’s based on averages of seen values, not projecting beyond them).
#➔ Conclusion:
  #🔵 Random Forest still slightly underpredicts for very large values — but that's expected and normal.

#Quick TL;DR:
#✨ Scaling and centering made the small-value predictions much tighter and helped stabilize the model.
#High-end underestimation is still present but overall, performance improved subtly.


########################
## splines #############
########################


enzyme_intermediate_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L14_modelling_supervised_regression/L14_dataset_enzyme_intermediate_data.rds"))

### since the relationship is not linear
### we don't know which variable is not linearly correlated
## but we can modify the workflow steps

enzyme_intermediate_split = initial_split(enzyme_intermediate_data)
enzyme_intermediate_training = training(enzyme_intermediate_split)
enzyme_intermediate_testing = testing(enzyme_intermediate_split)

lm_model <-
  linear_reg() %>% 
  set_engine("lm")

enzyme_recipe_nonlinear <- recipe(intermediate_a ~ ., ### note how in regression you can use a shortcut for all others
                                  data = enzyme_intermediate_training) %>% 
  step_center(all_predictors()) %>% 
  step_scale(all_predictors()) %>%
  step_interact(~ temperature:eA_rate)  %>% ## interaction term, which variable we want to model as an interaction, we are looking at the outcome
  step_ns(temperature, deg_free = 5) %>% ## splines for temperature
  step_ns(eA_rate, deg_free = 5) ## splines for enzyme rate

#1. recipe(intermediate_a ~ ., data = enzyme_intermediate_training)
#Set up a recipe for a regression problem.
#intermediate_a is the target (dependent variable).
#. means "use all other columns" as predictors (short-hand way).
#2. step_center(all_predictors())
#Center all predictor variables: subtract the mean.
#After this step, all predictors will have mean = 0.
#Helps models that are sensitive to scales (like regularization, interactions, splines).
#3. step_scale(all_predictors())
#Scale all predictor variables: divide by their standard deviation.
#After this step, all predictors will have standard deviation = 1.
#Ensures that all variables are on the same scale, which stabilizes model training.
#4. step_interact(~ temperature:eA_rate)
#Create an interaction term between temperature and eA_rate.
#Adds a new variable that is literally temperature * eA_rate.
#Why?: Sometimes the combination of two features is more predictive than the features separately.
#➔ Think of it like:
#  "How much the effect of temperature depends on the enzyme rate, and vice versa."
#5. step_ns(temperature, deg_free = 5)
#Apply a natural spline (nonlinear transformation) to temperature.
#deg_free = 5 means: allow 5 degrees of flexibility (knots) in the curve.
#Why?: Instead of fitting a straight line, this lets the model fit a wavy, curved relationship between temperature and outcome.
#➔ Think: temperature might have a nonlinear effect (e.g., too cold or too hot both being bad).
#6. step_ns(eA_rate, deg_free = 5)
#Same as above, but for eA_rate.
#Fit a nonlinear curve to eA_rate to capture complex relationships (like diminishing returns, optimal levels, etc.).
#🧠 Big Picture:
 # You are preparing your data to allow for:
  
  #Centered and scaled predictors (stable models).
#Interactions (complex relationships between variables).
#Nonlinear relationships (using splines for curves instead of assuming linearity).
#This is super smart especially for models that don't automatically capture nonlinearity (like linear regression),
#but even if you use a Random Forest, this can help if your goal is feature engineering.


lm_workflow <- workflow() %>% 
  add_model(lm_model) %>% 
  add_recipe(enzyme_recipe_nonlinear)


lm_wf_enzyme_fit <- fit(
  lm_workflow,
  enzyme_intermediate_training
)

enzyme_lm_wf_prediction = lm_wf_enzyme_fit %>%
  predict(enzyme_intermediate_testing) %>%
  bind_cols(enzyme_intermediate_testing)

enzyme_lm_wf_prediction %>%
  ggplot(aes(x=intermediate_a, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)

#What's happening in your plot:
#x-axis = the true values of intermediate_a
#y-axis = your model's predicted values .pred
#blue points = each prediction vs truth
#red line = perfect prediction line (where .pred = intermediate_a, i.e., if your model were perfect, all points would lie exactly on this red line)
#How to interpret it:
 # ✅ Good general trend:
  
 # Predictions roughly follow the red line: when the true intermediate_a increases, so does your prediction.
#That’s a good sign — your model learned something meaningful.
#❗ Some clear issues:
  
 # At low values of intermediate_a (near 0), your predictions are off — they are scattered and not tightly around the red line.
#At high values (above ~100–150), predictions are systematically underestimating — they are below the red line.
#Banded structure: the blue points seem to form distinct horizontal bands — that often suggests:
 # The model isn't capturing some fine-grained nonlinearities well.
#There may be categorical effects or piecewise behaviors not fully handled yet.
#In plain English:
#Your model is on the right track,
#but it’s still too simple compared to the complexity of the real relationship between predictors and intermediate_a.
#It’s missing some nonlinearity and possibly interaction patterns that the splines/interactions couldn't fully capture.

enzyme_lm_wf_prediction %>% 
  metrics(truth = intermediate_a, estimate = .pred)

## if we compare with the previous performance

enzyme_lm_prediction %>%
  metrics(truth = product, estimate = .pred)

## this has helped dramatically
## and has even improved compared to random forest method



############################
## feature selection #######
############################


enzyme_mix_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L14_modelling_supervised_regression/L14_dataset_enzyme_mix_data.rds"))
library(GGally)
## if we run
ggpairs(enzyme_mix_data)

## we can see that some of the variables are highly correlated
cor(enzyme_mix_data$enzymeA, enzyme_mix_data$enzymeB, method = "pearson")
## which is the value reported on the pairs plot
## other correlations
# substrate C and substrate A
# substtate D and substrate A
# eA rate and temperature
# enzymeB and enzymeA
# substrate C and sustrate D

## let's eliminate the following

enzyme_mix_reduced = enzyme_mix_data %>% 
  select(-c(substrateC, substrateD, enzymeA, temperature))


## now we use the random forest to predict again the intermediate_a

reduced_recipe = recipe(
  formula = intermediate_a ~ substrateA + substrateB + enzymeB + eA_rate,
  data = enzyme_mix_reduced) %>% 
  step_center(all_predictors()) %>% 
  step_scale(all_predictors())


## we can use the same model as earlier

rf_model_reg <- rand_forest() %>% 
  set_mode("regression") %>% 
  set_engine("ranger")


### create subsets

enzyme_reduced_split = initial_split(enzyme_mix_reduced)
enzyme_reduced_training = training(enzyme_reduced_split)
enzyme_reduced_testing = training(enzyme_reduced_split)


## and now build the workflow

rf_reduced_wf = workflow() %>% 
  add_recipe(reduced_recipe) %>% 
  add_model(rf_model_reg)


enzyme_reduced_fit = fit(
  rf_reduced_wf,
  enzyme_reduced_training
)


enzyme_reduced_prediction = enzyme_reduced_fit %>%
  predict(enzyme_reduced_testing) %>%
  bind_cols(enzyme_reduced_testing)

enzyme_reduced_prediction %>%
  ggplot(aes(x=intermediate_a, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)


enzyme_reduced_prediction %>% 
  metrics(truth = intermediate_a, estimate = .pred)


## we get a basically perfect prediction even if we used enzymeB instead of enzymeA


