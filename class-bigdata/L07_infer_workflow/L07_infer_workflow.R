########################################
## PART 1 - CATEGORICAL VARIABLES ######
########################################


###########################################################
### we use the same dataset used to visualise permutations
###########################################################
library(tidyverse)
dataCellCulture = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L07_infer_workflow/L07_dataset_resampling_cellculture.rds"))


##### what is our assumption in terms of relationships?
##### let's say we think the diameter depends on the cell type (alternative hypothesis H1)

library(infer)

dataCellCulture %>% 
  specify(formula = diameter ~ culture, success = "large") #function to say what is depending on what (relationships), the diameter (dependent) of the cell depends on the culture (independent) or cell type, success is the reference element

# in this case we have indicated the diameter as the response / outcome
# and as explanatory variable the culture (i.e. if you're cultureA you'll likely have diameter "large")
# discuss the concept of "success" in this context (reference element, point of view)
# factor is categorical type of data
## now we make a hypothesis as H0

# usually one indicates "point" for single samples tests
# and indicates "independence" for two samples tests, i.e. the outcome is independent
# of the sample measure belongs to

dataCellCulture %>% 
  specify(formula = diameter ~ culture, success = "large") %>%
  hypothesise(null = "independence")


## now we need to generate the permutations

dataCellCulture_replicates = dataCellCulture %>% 
  specify(formula = diameter ~ culture, success = "large") %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") ## this is important, i.e. we use permutations and not bootstrapping for generating the null distribution

## let's check the data have been produced as we intended
nrow(dataCellCulture_replicates)

## it's 1000 replicates of a dataset of 400 data points in the tibble, i.e. 400,000 data points


### now we need to calculate the summary statistics for the null distribution
### the statistic we are using is that proportions are different
### i.e. very similar to the example we have made in our in-house permutation procedure 

dataCellCulture_null_distribution = dataCellCulture %>% 
  specify(formula = diameter ~ culture, success = "large") %>%
  hypothesise(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in props", order = c("cultureA", "cultureB"))

dataCellCulture_null_distribution
### note how this tibble contains 1,000 rows = a value of the summary statistic
### per each of the permuted datasets

### we need to make our calculation of the summary statistic for the original sample
### i.e. omitting the generation of the permutations and null distribution

dataCellCulture_observation = dataCellCulture %>% 
  specify(formula = diameter ~ culture, success = "large") %>%
  calculate(stat = "diff in props", order = c("cultureA", "cultureB"))

dataCellCulture_observation

#### we now want to visualise the summary statistic compared with the null

visualize(dataCellCulture_null_distribution, bins = 10) +  #creates a histogram, collapse the values of x in values
  shade_p_value(obs_stat = dataCellCulture_observation, direction = "right")

### this corresponds to the observation we made when producing our in-house plots with permutations
### since we have a null distribution of the summary statistic we can compare the proportion
### of the cumulative distribution with our sample summary statistic and thus obtain the p-value

dataCellCulture_null_distribution %>% 
  get_p_value(obs_stat = dataCellCulture_observation, direction = "right") #depends on the randomness 

## it is obviously VERY significant, and we get a warning that p-values of 0 a suspicious
#if the test statistic is 0.17, and the p-value is 0.001 (<=0.005),then reject null hypothesis)

#########################################################
### PART 2 - CONTINUOUS VARIABLES #######################
#########################################################


CellCultureMedium = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L07_infer_workflow/L07_dataset_CellCultureMedium.rds"))


# let's explore the dataset
## NB: this is a preview of an approach we will use 
## in mode advanced classes in the course

library(GGally) #exploratory data analysis: how the data will look like, potential relationships of the variables (one to one), how each variable is distributed and combinations
ggpairs(CellCultureMedium, aes(color = medium))

### stop observing the plot, and make appropriate considerations


################################################
## TEST MEDIUM AND DIAMETER ####################
################################################


# Generate null hypothesis
CellCultureMedium_null_hypothesis <- CellCultureMedium %>% 
  specify(formula = diameter ~ medium) %>% 
  hypothesize(null = "independence") %>% 
  generate(reps = 1000, type = "permute") %>% 
  calculate(stat = "diff in means", order = c("blue_medium", "red_medium"))

# Generate observed statistics
CellCultureMedium_observed_stat <- CellCultureMedium %>% 
  specify(formula = diameter ~ medium) %>%
  calculate(stat = "diff in means", order = c("blue_medium", "red_medium"))

# Visualize the results using the plot function
visualise(CellCultureMedium_null_hypothesis)+
  shade_p_value(obs_stat = CellCultureMedium_observed_stat, 
                direction = "two-sided")

# get the p-value
CellCultureMedium_null_hypothesis %>%
  get_p_value(obs_stat = CellCultureMedium_observed_stat, direction = "two-sided")

#A larger observed statistic (e.g., a big difference in means) suggests a greater deviation from H₀.
#A smaller observed statistic suggests the sample data is closer to what H₀ predicts.
# Key Rule: Larger observed statistics usually lead to smaller p-values, and vice versa.
################################################
## TEST METABOLITE 3 AND DIAMETER ##############
################################################


# Generate null hypothesis
CellCultureMedium_null_hypothesis <- CellCultureMedium %>% 
  specify(formula = metabolite_3 ~ medium) %>% 
  hypothesize(null = "independence") %>% 
  generate(reps = 1000, type = "permute") %>% 
  calculate(stat = "diff in means", order = c("blue_medium", "red_medium"))

# Generate observed statistics
CellCultureMedium_observed_stat <- CellCultureMedium %>% 
  specify(formula = metabolite_3 ~ medium) %>%
  calculate(stat = "diff in means", order = c("blue_medium", "red_medium"))

# Visualize the results using the plot function
visualise(CellCultureMedium_null_hypothesis)+
  shade_p_value(obs_stat = CellCultureMedium_observed_stat, 
                direction = "two-sided")

# get the p-value
CellCultureMedium_null_hypothesis %>%
  get_p_value(obs_stat = CellCultureMedium_observed_stat, direction = "two-sided")
