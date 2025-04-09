
heart_disease_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L13_modelling_intro/L13_dataset_heart_disease_data.rds"))


## first let's split

heart_disease_split = initial_split(heart_disease_data, prop = 0.8)

## then training and testing

heart_disease_training = training(heart_disease_split)
heart_disease_testing = testing(heart_disease_split)

### now we prepare the model

rf_model <- rand_forest() %>% 
  set_mode("classification") %>% 
  set_engine("ranger")


heart_disease_fit = rf_model %>% 
  fit(heart_disease_risk ~ ., data = heart_disease_training)


## let's make a prediction and check it

heart_disease_predictions = heart_disease_testing %>% 
  bind_cols( #order of the rows is the same
    predict(heart_disease_fit, heart_disease_testing),
    predict(heart_disease_fit, heart_disease_testing, type = "prob")
  )


## let's quickly check how our predictions go
table(heart_disease_predictions$heart_disease_risk, heart_disease_predictions$.pred_class)
## we will discuss in the next class how we can improve this
#You have a confusion matrix (it looks like), with predictions vs. actual classes for heart disease risk categorized into Low, Medium, and High.
#The model is excellent at identifying "Low" risk patients.
#562 true positives (actual Low, predicted Low) and zero mistakes for Low being classified as Medium or High.
#So Low-risk people are almost perfectly classified.
#The model struggles with Medium and High risk.
#For Medium risk:
 # 63 were wrongly classified as Low.
#106 correctly classified as Medium.
#2 wrongly classified as High.
#For High risk:
 # 43 were classified as Medium.
#Only 3 correctly classified as High.
#High-risk patients are often misclassified.
#Only 3 High-risk patients were properly identified as High.
#43 High-risk patients were classified as Medium (which is bad — we're underestimating their risk!).
#Overall conclusions:
#Strength: Very good at predicting Low risk.
#Weakness: Dangerous underestimation of High-risk cases (classifying them as Medium).
#Clinical risk: This could be a serious problem because missing high-risk patients might mean they don't get the urgent care they need.