
library(tidymodels)
library(tidyverse)

logreg_variants = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L15_modelling_supervised_classification/L15_dataset_logreg_variants.rds"))


rf_model_tuning <- rand_forest( #use a question mark in the console
  mtry = tune(),
  trees = tune(),
  min_n = tune()
) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")


rf_tuning_grid <- grid_regular(mtry(range = c(5L,8L)),
                          trees(),
                          min_n(),
                          levels = 3)
#What's happening step-by-step?
#grid_regular():
#Creates a regular grid of hyperparameter values — meaning evenly spaced values for each parameter across their range.
#mtry(range = c(5L, 8L)):
#You are telling it to try different values of mtry (number of variables randomly sampled at each split), between 5 and 8.
#trees():
#Include different values for the total number of trees in the forest.
#(Default range will be used unless you specify.)
#min_n():
#Include different values for min_n, which is the minimum number of data points in a node for the node to be split further.
#levels = 3:
#For each parameter, you want 3 evenly spaced values across their range.
#So what will the rf_tuning_grid contain?
#It will be a data frame of all possible combinations of:

#3 different mtry values (between 5 and 8)
#3 different trees values
#3 different min_n values
#→ So you’ll get 
#3×3×3=27 combinations in total! 🚀

#Why do this?
#This grid will later be used in hyperparameter tuning (with tune_grid()) to find the best settings for your Random Forest model — based on performance (like accuracy, ROC AUC, etc.).
#creates a grid of possible predictor combinations.
## testing / training / validation
## pay attention to the concept

set.seed(324)
variants_new_split = initial_split(logreg_variants %>% 
                                     dplyr::select(-c(individual)) %>% 
                                     mutate(phenotype = factor(phenotype, levels = c("control", "case"))),
                                   prop = 0.75)
variants_new_training = training(variants_new_split)
variants_new_testing = testing(variants_new_split)

## now we further split the training into training itself and validation of the step
#random sampling of the training data
set.seed(234)
variants_folds <- vfold_cv(variants_new_training)


## the recipe is going to be the same, as it defines the characteristics
## of the input, relationships of the variables and transformations

predictors <- names(logreg_variants)[!(names(logreg_variants) %in% c("individual", "phenotype"))]


rf_variants_recipe <- recipe(
  as.formula(
    paste0("phenotype ~ ", paste0(predictors, collapse = " + "))
  ),
  data = variants_new_training
) %>% 
  step_dummy(all_predictors()) %>% 
  step_normalize()

## the workflow instead is created according to the above

rf_class_tune_wf <- workflow() %>% 
  add_model(rf_model_tuning) %>% 
  add_recipe(rf_variants_recipe)

## the code to run the fitting looks slightly different
## since we need to perform a grid tuning
## the following code might take a while
## in case too long, stop and load results

# rf_tuning_results <- 
#   rf_class_tune_wf %>% 
#   tune_grid(
#     resamples = variants_folds,
#     grid = rf_tuning_grid
#   )

rf_tuning_results = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L15_modelling_supervised_classification/L15_dataset_rf_tuning_results.rds"))

### we can inspect the outcome metrics as usual

rf_tuning_results %>% 
  collect_metrics()

### we can plot these results

rf_tuning_results %>% 
  collect_metrics() %>% 
  ggplot(aes(x=trees, y=mean, color = factor(min_n)))+
  geom_line(linewidth = 1.5, alpha = 0.6) +
  geom_point(size = 2) +
  facet_wrap(~ .metric, scales = "free", nrow = 2) +
  scale_x_log10(labels = scales::label_number()) +
  scale_color_viridis_d(option = "plasma", begin = .9, end = 0)
#the higher the number of trees in the forest, the more accurate it is 

rf_tuning_results %>% 
  collect_metrics() %>% 
  ggplot(aes(x=trees, y=mean, color = factor(min_n)))+
  geom_line(linewidth = 1.5, alpha = 0.6) +
  geom_point(size = 2) +
  facet_wrap(.metric ~ mtry, ncol = 3) +
  scale_x_log10(labels = scales::label_number()) +
  scale_color_viridis_d(option = "plasma", begin = .9, end = 0)


### we can also show the best result according to one
### metrics

rf_tuning_results %>%
  show_best("accuracy")


## and we can select the model in a model object

rf_tuning_best_params = rf_tuning_results %>%
  select_best("accuracy")

### in order to USE the params for predictions
### we need to "finalise" the workflow after tuning
### using the best model we just saved

final_rf_wf <- rf_class_tune_wf %>% 
  finalize_workflow(rf_tuning_best_params)

## and do a "last" fit on the split data which will automatically
## run on the test split

final_rf_fit <- final_rf_wf %>% 
  last_fit(variants_new_split) #not fit

## metrics

final_rf_fit %>% 
  collect_metrics()

final_rf_fit %>%
  collect_predictions() %>% 
  roc_curve(phenotype, .pred_control) %>% 
  autoplot()


### we can also inspect the model itself
### by using the best params and saving the model
### instead of a final workflow

rf_tuning_best_model <- finalize_model(
  rf_model_tuning, ## this is the model we initially created with tune placeholders
  rf_tuning_best_params ## these are the best parameters identified in tuning
)

#important predictors to allow the model to reach the prediction, and not association between the predictor and the outcome
library(vip)


rf_tuning_best_model %>%
  set_engine("ranger", importance = "permutation") %>% #swap the labels of the predictors, and see if the predictors changing if they have an effect on the prediction/ or performance of the model
  fit(
    as.formula(
    paste0("phenotype ~ ", paste0(predictors, collapse = " + "))
    ),
    data = variants_new_testing
  ) %>%
  vip(geom = "point")
