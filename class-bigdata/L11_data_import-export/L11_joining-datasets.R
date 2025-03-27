
library(tidyverse)
### introducing tribble(), simple table, not convenient for big data


band = tribble(
  ~name, ~band,
  "Mick", "Stones",
  "John", "Beatles",
  "Paul", "Beatles"
)


instrument <- tribble(
  ~name, ~plays,
  "John", "guitar",
  "Paul", "bass",
  "Keith", "guitar"
)


### the effect of different joins

### LEFT JOIN, only the rows of the left dataset

band %>% 
  left_join(instrument, by = "name")


### RIGHT JOIN, only the rows of the right dataset

band %>% 
  right_join(instrument, by = "name")


### FULL JOIN, no overlap (union of the datasets)

band %>% 
  full_join(instrument, by = "name")


### INNER JOIN, handling the overlap

band %>% 
  inner_join(instrument, by = "name")
