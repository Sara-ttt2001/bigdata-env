#In the hist() function in R, the argument freq controls whether the y-axis represents frequency counts or density values in a histogram.

#Explanation of freq Argument
#freq = TRUE (default):
  #The histogram bars represent raw counts (i.e., the number of observations in each bin).
#The sum of all bar heights equals the total number of observations.
#freq = FALSE:
  #The histogram bars represent density values instead of counts.
#The sum of the bar areas equals 1, making it comparable to a probability density function (PDF).


x <- rnorm(1000, mean = 0, sd = 1)  # Generate 1000 random normal values
hist(x, freq = TRUE, main = "Histogram with Frequency", xlab = "x", ylab = "Frequency")


hist(x, freq = FALSE, main = "Histogram with Density", xlab = "x", ylab = "Density")
