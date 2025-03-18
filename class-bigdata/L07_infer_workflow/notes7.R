#infer verbs:
#specify (imp step: describes the relationship between the variables in the data set)
#hypothesize (consider the null hypothesis distribution, independence or dependence)
#generate (optional: to create the permutation in empirical null distributions)
#calculate (for the test statistic on the original data set and the generated)
#visualize
#structure follows the logic


#To determine whether to accept or reject the null hypothesis ((H_0)), you need to look at the p-value obtained from the permutation test.

### **Interpreting the Results:**
#1. **Null Hypothesis ((H_0))**: There is no relationship between **culture type** and **diameter** (i.e., the proportions of "large" diameters are independent of culture type).
#2. **Alternative Hypothesis ((H_1))**: The proportion of "large" diameters **differs** between the two culture types.
#3. **Permutation Test**: You generated a null distribution by permuting the culture labels and recalculating the difference in proportions 1000 times.
#4. **Observed Statistic**: You computed the actual difference in proportions from the original dataset.
#5. **p-value Calculation**: The p-value is the proportion of permuted datasets where the test statistic is at least as extreme as the observed statistic.

### **Decision Rule:**
#- If ( p <= 0.05 ): Reject ( H_0 ) (strong evidence that culture type affects diameter).
#- If ( p > 0.05 ): Fail to reject ( H_0 )means accept H0 (not enough evidence to conclude a relationship).

### **What to Do Next?**
#- If your p-value is small (e.g.,( p <= 0.05)), you **reject** the null hypothesis and conclude that the cell type **does** influence the diameter (dependence).
#- If your p-value is large (e.g.,( p > 0.05 )), you **fail to reject/accept** the null hypothesis, meaning there is **no strong evidence** that culture type affects diameter (independence).
