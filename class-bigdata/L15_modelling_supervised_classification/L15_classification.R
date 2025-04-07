
logreg_variants = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L15_modelling_supervised_classification/L15_dataset_logreg_variants.rds"))


library(tidymodels)
library(tidyverse)

variants_split = initial_split(logreg_variants %>% 
                                 dplyr::select(-c(individual)) %>% 
                                 mutate(phenotype = factor(phenotype, levels = c("control", "case"))),
                               prop = 0.75)
#logreg_variants %>%
 # You're starting with a data frame called logreg_variants.
#select(-c(individual))
#You remove the column called individual.
#Maybe because it’s an ID column (useless for modeling).
#We usually remove IDs since they don't carry predictive information.
#mutate(phenotype = factor(phenotype, levels = c("control", "case")))
#You transform the phenotype column:
 # Turn it into a factor (i.e., categorical variable in R).
#You set the levels order to be control first, then case.
#Why? → Probably because you're setting it up for logistic regression, and R by default models the second level (case) as the "positive" outcome when fitting models like glm(), etc.
#initial_split(..., prop = 0.75)
#You split the dataset:
#75% of the data goes into the training set.
#25% goes into the testing set.
#It creates an object (variants_split) that you can later use to pull out the training/testing sets with training(variants_split) and testing(variants_split).
#In short:
#✅ Remove IDs,
#✅ Fix the target variable (phenotype) to be a properly ordered factor,
#✅ Split into training and testing sets, keeping 75% for training.



variants_training = training(variants_split)
variants_testing = testing(variants_split)


logistic_model <- logistic_reg() %>% 
  set_engine("glm") %>% #the outcome is 2 categories or more, it differs, pay attention to the number of possible values of the outcome
  set_mode("classification")

variants_recipe <- recipe(phenotype ~ ., data = variants_training) %>% 
  step_dummy(all_nominal_predictors()) %>% #converts categorical predictors into numerical predictors, for representation only
  step_normalize()

logreg_wf_variants <- workflow() %>% 
  add_recipe(variants_recipe) %>% 
  add_model(logistic_model)


logreg_variants_fit <- fit(
  logreg_wf_variants,
  variants_training
)
#fitting is with the workflow and with the training data

tidy(logreg_variants_fit)
#case-when inside the mutate, and transform the dataset and assign values to the genotype
## we can convert the estimates to an odds-ratio
## and also filter nominally significant variants

tidy(logreg_variants_fit, exponentiate = TRUE) %>% 
  filter(p.value < 0.05) 
#the estimate values are exponentiated
#Step-by-step:
#  tidy(logreg_variants_fit, exponentiate = TRUE)
#logreg_variants_fit is probably your fitted logistic regression model (maybe using glm() or via parsnip from tidymodels).
#tidy() comes from the broom package. It turns model output into a neat data frame.
#exponentiate = TRUE means:
 # Exponentiate the coefficients (i.e., exp(coef)).
#In logistic regression, the raw coefficients are in log-odds, and exponentiating them gives you odds ratios (easier to interpret!).
#Example:
  
  #Log-odds coefficient: 0.7 → Odds ratio: exp(0.7) ≈ 2.01
#(meaning about 2× increase in odds).
#filter(p.value < 0.05)
#You keep only the variables where the p-value is less than 0.05.
#This means you're filtering for statistically significant predictors (at the 5% level).
#So what does the full code do?
#✅ Summarizes your logistic regression model,
#✅ Converts coefficients into odds ratios,
#✅ Keeps only predictors that are statistically significant.

#✨ Summary:
#In one line:
#"Show me the significant predictors of case vs. control, expressed as odds ratios."


phenotype_variants_prediction = bind_cols(
  variants_testing %>% dplyr::select(phenotype),
  logreg_variants_fit %>% 
    predict(variants_testing, type = "class"),
  logreg_variants_fit %>% 
    predict(variants_testing, type = "prob")
)
  
phenotype_variants_prediction %>% metrics(truth = phenotype, estimate = .pred_class)

precision(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)
recall(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)

###########################################
## now let's see by selecting the variants

sig_variants = tidy(logreg_variants_fit, exponentiate = TRUE) %>% 
  filter(p.value < (0.05/100)) %>% ## remember bonferroni correction
  filter(term != "(Intercept)") %>% 
  mutate(
    variant = sub("^(chr.+_.+)_X.+$", "\\1", term)
  ) %>% 
  pull(variant) %>% unique()

## the number of nominally significant variants is:
length(sig_variants)

## we use for the formula only the significant variants
## have a look at what the paste0 code does
#feature selection:
variants_selection_recipe <- 
  recipe(as.formula(paste0("phenotype", "~", paste0(sig_variants, collapse = " + "))), #to convert the string into a formula
         data = variants_training) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize()

logreg_wf_selected_variants <- workflow() %>% 
  add_recipe(variants_selection_recipe) %>% 
  add_model(logistic_model)


logreg_selected_variants_fit <- fit(
  logreg_wf_selected_variants,
  variants_training
)


phenotype_selected_variants_prediction = bind_cols(
  variants_testing %>% dplyr::select(phenotype),
  logreg_selected_variants_fit %>% 
    predict(variants_testing, type = "class"),
  logreg_selected_variants_fit %>% 
    predict(variants_testing, type = "prob")
)

phenotype_selected_variants_prediction %>% metrics(truth = phenotype, estimate = .pred_class)

## current model
precision(phenotype_selected_variants_prediction, truth = phenotype, estimate = .pred_class)
recall(phenotype_selected_variants_prediction, truth = phenotype, estimate = .pred_class)

## previoius model
precision(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)
recall(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)

## we have modestly improved in precision, not much in recall
f_meas(phenotype_variants_prediction, truth = phenotype, estimate = .pred_class)
f_meas(phenotype_selected_variants_prediction, truth = phenotype, estimate = .pred_class)
## overall a modest improvement in accuracy


################################################
### RANDOM FOREST CLASSIFIER ###################
################################################

library(tidymodels)

rf_model <- rand_forest() %>% 
  set_mode("classification") %>% 
  set_engine("ranger")

predictors <- names(logreg_variants)[!(names(logreg_variants) %in% c("individual", "phenotype"))] #excluding individual and phenotype

rf_variants_recipe <- recipe(
  as.formula(
    paste0("phenotype ~ ", paste0(predictors, collapse = " + "))
  ),
  data = variants_training
) %>% 
  step_dummy(all_predictors()) %>% 
  step_normalize()

rf_class_wf <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(rf_variants_recipe)

rf_class_fit <- fit(
  rf_class_wf,
  variants_training
)


phenotype_rf_prediction = bind_cols(
  variants_testing %>% dplyr::select(phenotype),
  rf_class_fit %>% 
    predict(variants_testing, type = "class"),
  rf_class_fit %>% 
    predict(variants_testing, type = "prob")
)


precision(phenotype_rf_prediction, truth = phenotype, estimate = .pred_class)
recall(phenotype_rf_prediction, truth = phenotype, estimate = .pred_class)
f_meas(phenotype_rf_prediction, truth = phenotype, estimate = .pred_class)
