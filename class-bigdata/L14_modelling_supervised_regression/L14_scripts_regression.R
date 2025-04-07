

library(tidyverse)
library(tidymodels)
tidymodels_prefer()


enzyme_process_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L14_modelling_supervised_regression/L14_dataset_enzyme_process_data.rds"))


## FIRST WE SPLIT the dataset into training and testing
set.seed(358)

enzyme_split = initial_split(enzyme_process_data, prop = 0.75)
enzyme_training = training(enzyme_split)
enzyme_testing = testing(enzyme_split)


########################
# LINEAR REGRESSION ####
########################

### define the mathematical structure

lm_model <-
  linear_reg() %>% 
  set_engine("lm")


## fit the model, by defining the relationship
## between the variables

enzyme_lm_formula_fit <-
  lm_model %>% 
  fit(product ~ ., data = enzyme_training) #product is y, the dependent variable, the outcome


## now there's several ways to inspect the model
## simplest is just

enzyme_lm_formula_fit

## what has been printed is the fit of the model
## which can also be extracted with

enzyme_lm_formula_fit %>% extract_fit_engine()


## ths function allows to apply further methods to the fitted model
## such as

## best way to summarise is using a coherent tidymodels function

tidy(enzyme_lm_formula_fit)


enzyme_lm_prediction = enzyme_lm_formula_fit %>%
  predict(enzyme_testing) %>%
  bind_cols(enzyme_testing)


enzyme_lm_prediction %>%
  ggplot(aes(x=product, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+ #alpha means the transparency, the discrimination between the points plotted
  geom_abline(colour = "red", alpha = 0.9)
#the prediction does not fit the data, predictions are all over the plot
#non-linear
#1. The model is not fitting the data well.

#The scatter of the points (blue dots) clearly shows a curved, nonlinear pattern.
#But the red line (your linear regression) is straight.
#➔ Conclusion: A simple linear model cannot capture the true relationship between product and .pred.
#2. The predictions are biased.

#For small values of product, the model underestimates (points are above the line).
#For large values, it overestimates or misses (points far from the line).
#➔ Conclusion: The model's errors are not random, which suggests systematic bias.
#3. Nonlinear relationship exists.

#The data seems to grow faster than linear for low product values, and then levels off.
#➔ Conclusion: You might need a nonlinear model (e.g., polynomial regression, or a more flexible model like random forests or splines).
#Summary in one sentence:

#🔥 The relationship between product and .pred is clearly nonlinear, and a simple linear regression is not appropriate to model this data accurately.

########################
# NEAREST NEIGHBOURS ###
########################


knn_reg_model <-
  nearest_neighbor(neighbors = 5, weight_func = "triangular") %>% #property of the function
  # This model can be used for classification or regression, so set mode
  set_mode("regression") %>%
  set_engine("kknn")

knn_reg_model

#knn is always with training data

enzyme_knn_formula_fit <-
  knn_reg_model %>% 
  fit(formula = product ~ temperature + substrateA + substrateB + enzymeA + enzymeB + enzymeC + eA_rate + eB_rate + eC_rate, 
      data = enzyme_training)
#knn does not work well with a dot

enzyme_knn_prediction = enzyme_knn_formula_fit %>%
  predict(enzyme_testing) %>%
  bind_cols(enzyme_testing)



enzyme_knn_prediction %>%
  ggplot(aes(x=product, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)

#not a good prediction higher (minute 42)
#1. The fit looks somewhat better but still has problems.

#Compared to the previous plot, the points are less curved and more aligned along the diagonal.
#However, there’s still a lot of scatter — especially at higher product values.
#➔ Conclusion: The relationship is closer to linear, but still not perfectly captured by a simple straight line.
#2. KNN seems to have "smoothed" the relationship.

#KNN probably helped reduce extreme nonlinear effects.
#However, KNN itself is a non-parametric method, not inherently linear — so forcing a linear model after KNN may still lose information.
#➔ Conclusion: While the data is "cleaner", linear regression might still not be the ideal model here.
#3. The model still suffers from variance issues.

#Especially for larger product values (e.g., >2000), you can see points spread out a lot vertically.
#➔ Conclusion: Prediction uncertainty increases with product — you might need a model that handles heteroscedasticity (non-constant variance), or one that models the spread better (like quantile regression).
#TL;DR:
 # ✨ After KNN, the data appears more linear but a simple linear regression still does not perfectly capture the pattern — especially at higher product values.
#You’ve improved it, but there’s still room to use nonlinear models or variance-adjusted models for better performance.
#########################
## RANDOM FOREST ########
#########################


rf_model_reg <- rand_forest() %>% 
  set_mode("regression") %>% 
  set_engine("ranger")


enzyme_rf_formula_fit <-
  rf_model_reg %>% 
  fit(formula = product ~ temperature + substrateA + substrateB + enzymeA + enzymeB + enzymeC + eA_rate + eB_rate + eC_rate, 
      data = enzyme_training)


enzyme_rf_prediction = enzyme_rf_formula_fit %>%
  predict(enzyme_testing) %>%
  bind_cols(enzyme_testing)

#pass the fit to the prediction, predict the testing, and then add a column of the prediction to the testing


enzyme_rf_prediction %>%
  ggplot(aes(x=product, y=.pred))+
  geom_point(alpha = 0.4, colour = "blue")+
  geom_abline(colour = "red", alpha = 0.9)
#better but still not perfect (qualitative)
#1. The predictions (.pred) are much tighter around the diagonal.

#Points are clustered closer to the red line (which represents a perfect prediction).
#There’s less spread, especially in the low to medium product values.
#➔ Conclusion:
#  ✅ Random Forest is capturing the relationship much better than both simple Linear Regression and KNN.

#2. High product values still show a bit of deviation.

#For very large product values (>2000), predictions start to underestimate a bit (points fall below the red line).
#But overall, it's much less problematic than before.
#➔ Conclusion:
#🔵 Minor bias for very high values, but Random Forest still generalizes much better across the range.

#3. Random Forest handles nonlinearity naturally.

#Unlike linear regression, Random Forest can model complex, nonlinear relationships without requiring transformations.
#That's probably why you now have better alignment and lower variance.
#➔ Conclusion:
 # 🌳 Random Forest is a much more appropriate model for this dataset.

#Quick TL;DR:
 # ✨ After Random Forest, the predictions are much closer to the true values, the spread is reduced, and the model performs way better overall.
#Only very large values still show a slight underprediction.