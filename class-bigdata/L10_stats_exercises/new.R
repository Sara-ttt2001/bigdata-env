library(tidyverse)
library(infer)
dataExposure = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L10_stats_exercises/exercise_01/L10_dataset_exercise01.rds"))

table(dataExposure$condition, dataExposure$drinking)

chisq_base = chisq.test(
  table(dataExposure$condition, dataExposure$drinking)
)
chisq_base
#in this case h0 is independent, h1 is dependent, not significant, therefore accept H0
table(dataExposure$condition, dataExposure$smoking)

chisq_base2 = chisq.test(
  table(dataExposure$condition, dataExposure$smoking)
)
chisq_base2
#reject h0

table(dataExposure$condition, dataExposure$sport)

chisq_base3 = chisq.test(
  table(dataExposure$condition, dataExposure$sport)
)
chisq_base3
#reject H0
##################################
library(infer)
dataHappyness = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L10_stats_exercises/exercise_02/L10_dataset_exercise_02.rds"))
obs_dataHappyness = dataHappyness %>% 
  specify(endorphin_level ~ happyness) %>% 
  calculate(stat = "diff in means", order = c("usually_happy","rarely_happy"))

null_dataHappyness = dataHappyness %>% 
  specify(endorphin_level ~ happyness) %>% 
  hypothesize(null = "independence") %>% 
  generate(reps = 1000, type = "permute") %>% 
  calculate(stat = "diff in means", order = c("usually_happy","rarely_happy"))

null_dataHappyness %>%
  visualise()+
  shade_p_value(obs_dataHappyness, direction = "two-sided")

 null_dataHappyness %>%
  get_p_value(obs_stat = obs_dataHappyness,
              direction = "two-sided")


 
 obs_dataHappyness1 = dataHappyness %>% 
   specify(serotonin_level ~ happyness) %>% 
   hypothesize(null = "independence") %>% 
   calculate(stat = "diff in means", order = c("usually_happy","rarely_happy"))
 
 null_dataHappyness1 = dataHappyness %>% 
   specify(serotonin_level ~ happyness) %>% 
   hypothesize(null = "independence") %>% 
   generate(reps = 1000, type = "permute") %>% 
   calculate(stat = "diff in means", order = c("usually_happy","rarely_happy"))
 
 null_dataHappyness1 %>%
   visualise()+
   shade_p_value(obs_dataHappyness1, direction = "two-sided")
 
 null_dataHappyness1 %>%
   get_p_value(obs_stat = obs_dataHappyness1,
               direction = "two-sided")
 #################################
 dataCytofluorimeter = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L10_stats_exercises/exercise_03/L10_dataset_exercise03.rds"))
  
head(dataCytofluorimeter)
ggplot(dataCytofluorimeter, aes(x=CD123, y=CD345))+
  geom_point()
datacytofluorimeter_correlation_observed <- dataCytofluorimeter %>% 
  specify(CD123 ~ CD345) %>%
  calculate(stat = "correlation")
#NOT CORRELATED

head(dataCytofluorimeter)
ggplot(dataCytofluorimeter, aes(x=CD345, y=CD876))+
  geom_point()
datacytofluorimeter_correlation_observed1 <- dataCytofluorimeter %>% 
  specify(CD345 ~ CD876) %>%
  calculate(stat = "correlation")
#CORRELATED

ggplot(dataCytofluorimeter, aes(x=CD123, y=CD876))+
  geom_point()
datacytofluorimeter_correlation_observed2 <- dataCytofluorimeter %>% 
  specify(CD123 ~ CD876) %>%
  calculate(stat = "correlation")
#NOT CORRELATED

#####################################

dataReactor = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L10_stats_exercises/exercise_04/L10_dataset_exercise04.rds"))

dataReactor_observed = dataReactor %>% 
  specify(formula = proteinA ~ bioreactor) %>% 
  hypothesise(null = "independence") %>% 
  calculate(stat = "F")

dataReactor_null = dataReactor %>% 
  specify(formula = proteinA ~ bioreactor) %>% 
  hypothesise(null = "independence") %>% 
  generate(reps = 1000, type = "permute") %>% 
  calculate(stat = "F")

dataReactor_null %>%
  visualise()+
  shade_p_value(
    obs_stat = dataReactor_observed,
    direction = "two-sided"
  )

p_value_data = dataReactor_null %>%
  get_p_value(obs_stat = dataReactor_observed,
              direction = "two-sided")
#accept h0

