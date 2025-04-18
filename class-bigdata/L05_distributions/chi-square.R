##########################
## what a chi-square is
#########################

set.seed(345) # a starting point for a random calculation that sets reproducibility
samplesize = 10
pop_mean = 5
pop_variance = 4

# Generate 1000 normal distributions
norm_dists <- replicate(10000, rnorm(samplesize, mean = pop_mean, sd = sqrt(pop_variance))) #generate 10,000 samples of size 10 in normal distribution

## this means the variance = sd^2 = 4

chi_stat <- function(variance){
  stat = ((samplesize-1)*variance)/pop_variance #calculating the z-score
  return(stat)
}

# Calculate the mean of each normal distribution
variances <- apply(norm_dists, 2, var)
chisquares <- unlist(lapply(variances, chi_stat))


# Plot the distribution of variances
hist(chisquares, main = "Distribution of Chi Square", xlab = "Chi Square value", freq = FALSE)

# Add a normal distribution to the plot
x <- seq(min(chisquares), max(chisquares), length = 10000)
curve(dchisq(x, df = samplesize-1), add = TRUE, col = "blue", lwd = 2)


#################################
## expected counts in chi-square
#################################


# Create the 3x2 table
table <- matrix(c(20, 30, 40, 50, 10, 30), nrow = 3, byrow = TRUE)
dimnames(table) <- list(c("Group A", "Group B", "Group C"), c("Category 1", "Category 2"))

table

# Calculate row and column totals
row_totals <- apply(table, 1, sum) #1 here means for rows
col_totals <- apply(table, 2, sum) #2 here means for columns
total <- sum(table)

# Calculate expected counts for Category 1 and Category 2
expected_counts <- outer(row_totals, col_totals, "*") / total


# Print the table with observed and expected counts
cbind(table, expected_counts)



