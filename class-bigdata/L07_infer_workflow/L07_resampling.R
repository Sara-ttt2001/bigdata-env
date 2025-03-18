
library(tidyverse)
dataCellCulture = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L07_infer_workflow/L07_dataset_resampling_cellculture.rds"))

### let's save the plot with the proportions of the two cell types
original_proportions = ggplot(dataCellCulture, aes(x=culture, fill = diameter))+
  geom_bar(position = "fill")

## and display it
original_proportions

## we can also group by the two variables and use the function
## tally() to count the occurrences in each group
## if we then pivot_wider we have a 2x2 that's suitable for chi-square test
dataCellCulture %>%
  group_by(culture, diameter) %>%
  tally() %>% #summarize n= n (), numerosity or counts
  pivot_wider(
    names_from = diameter, #display it in a wider version for comparison (visualization)
    values_from = n
  )


### let's see what a permutation looks like
### we use the function sample()


dataCellCulture = dataCellCulture %>%
  mutate(
    reshuffled = sample(diameter, length(diameter), replace = FALSE) #sample function: to do resampling, where you're taking the sample, how large is the sample(sample size), replacement
  ) #not changing the number of cells and the diameter

## we prepare a plot with the permuted proportions
permuted_proportions = ggplot(dataCellCulture, aes(x=culture, fill = reshuffled))+
  geom_bar(position = "fill")

## and display it
permuted_proportions


dataCellCulture %>%
  select(culture, reshuffled) %>%
  group_by(culture, reshuffled) %>%
  tally() %>%
  pivot_wider(
    names_from = reshuffled, #reshuffling is random 
    values_from = n
  )


library(cowplot) ## needs up to date container

plot_grid(
  original_proportions,
  permuted_proportions,
  labels = c('original', 'permuted'),
  ncol = 2,
  align = 'v'
)
#changing the proportion between the two, without changing the sample size, or numerosity or the diameter

#### let's define a test to evaluate the extent of the difference
#### i.e. the proportion between normal / large and the difference between
#### the two cell cultures

### in the original dataset it would be 

ratio = dataCellCulture %>%
  group_by(culture, diameter) %>%
  tally() %>%
  pivot_wider(
    names_from = diameter,
    values_from = n
  ) %>%
  mutate(
    ratio = large / normal
  ) %>%
  pull(ratio) #returning a vector

proportion = ratio[1]/ratio[2]

######## we can now replicate this procedure 100 times

proportions = replicate(100, {
  ratio = dataCellCulture %>%
    mutate(
      reshuffled = sample(diameter, length(diameter), replace = FALSE)
    ) %>%
    select(culture, reshuffled) %>%
    group_by(culture, reshuffled) %>%
    tally() %>%
    pivot_wider(
      names_from = reshuffled,
      values_from = n
    ) %>%
    mutate(
      ratio = large / normal
    ) %>%
    pull(ratio)
  proportion = ratio[1]/ratio[2]
  return(proportion)
})

hist(proportions, xlim = c(0,3))
abline(v = proportion, col='red', lwd=3, lty='dashed')
