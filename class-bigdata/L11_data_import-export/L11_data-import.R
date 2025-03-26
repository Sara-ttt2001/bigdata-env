### READR functions
### how to look at a function's options
library(tidyverse)
formals(read_tsv)

names(formals(read_tsv))
names(formals(read_csv))

### one can compare options of different functions

intersect(names(formals(read_tsv)), names(formals(read_csv)))

identical(names(formals(read_tsv)), names(formals(read_csv)))

## why this is false?
## let's order the options

identical(
  names(formals(read_tsv))[order(names(formals(read_tsv)))], 
  names(formals(read_csv))[order(names(formals(read_csv)))]
  )

check = c("george", "mary","lucas")
order(check)
check[order(check)] #based on alphabetical order
##################################################
## READING DATA 
##################################################

### NIMBUS DATASET 

data = url("L11_dataset_nimbus.csv")

## one can read from the web
nimbus = read_csv("L11_dataset_nimbus.csv")
## or alternatively reaad it locally


## what do you observe?
nimbus

## inspect one single element
## observe the role of the function pull()
nimbus %>% pull(ozone) %>% class() #pull: returns a vector, class shows the type of the vector, variable is treated as an object

## one can obtain a similar result with the function pluck()
## observe the difference between the two
nimbus %>% pluck("ozone") %>% class() # variable is treated as a character in using pluck

## what is the conclusion of the vector type
## compare it with visual inspection of the above dataset
## why is that?

nimbus %>% pluck("ozone") %>% unique() #the unique values of the vector, without taking the repeated values
#numbers can be converted as characters, but not vice versa.
## observe better

## let's add an option

nimbus = read_csv("L11_dataset_nimbus.csv", na = ".") #na says what is the missing value (not being measured, not assigned)

nimbus

## see what's changed
nimbus %>% pluck("ozone") %>% class()

## we can manually specify the column types

nimbus = read_csv("L11_dataset_nimbus.csv", 
					na = ".",
					col_types = list(
                    ozone = col_double() #showing the type of the column (another way)
					)
					)

### let's see the result
nimbus

## look at all possible col types
?cols()
## and choose readr package

