#Here’s how to interpret the output from your regression model:
  
  #Intercept (β₀):
  #Estimate: 9.94
#Interpretation: When sugar = 0, the predicted insulin level is 9.94. Although the intercept might not always have a meaningful real-world interpretation, this value gives you a baseline insulin level when there is no sugar.
#Slope (β₁):
 # Estimate for sugar: 2.01
#Interpretation: For each 1-unit increase in sugar, the insulin level is predicted to increase by 2.01 units. This suggests a positive correlation between sugar and insulin levels: higher sugar levels are associated with higher insulin levels.
#P-values:
  #Both the intercept and the slope have p-values of 0. This is statistically significant, indicating that both the intercept and the relationship between sugar and insulin are highly unlikely to be due to random chance.
#Standard Errors:
 # The standard errors for both the intercept (0.0490) and the sugar coefficient (0.00477) are relatively small, indicating that the estimates are precise.
#Summary:
  #The positive slope (2.01) and the statistically significant p-value (<0.05) suggest that as sugar levels increase, insulin levels increase as well. This is a clear positive relationship.

##########################################################
#Here’s how to interpret your logistic regression results:

#1. Intercept (β₀)
#Estimate: -0.184
#Interpretation:
 # When genotype_reg = 0 (i.e., 0/0 genotype), the log-odds of being a patient (condition = 1) is -0.184.
#Since this is in log-odds, converting it to probability would require using the logistic function.
#2. Genotype Effect (β₁)
#Estimate: 0.238
#Interpretation:
 # For each one-unit increase in genotype_reg (moving from 0/0 → 0/1 → 1/1), the log-odds of being a patient increase by 0.238.
#This suggests that as genotype increases, the likelihood of being a patient increases.
#3. Statistical Significance
#P-value for genotype_reg: 0.000219 (very small, < 0.05)
#Conclusion: The effect of genotype on condition is statistically significant.
#This means that genotype is strongly associated with the likelihood of being a patient.
#4. Odds Ratio
#To get a more intuitive interpretation, we can convert the estimate into an odds ratio:
  
 # Odds Ratio
#≈1.27

#Interpretation: For each step increase in genotype (0/0 → 0/1 → 1/1), the odds of being a patient increase by 27%.
#Summary
#Genotype significantly affects condition status (p < 0.05).
#Higher genotype values are associated with a higher probability of being a patient.
#Each step increase in genotype increases the odds of being a patient by ~27%.