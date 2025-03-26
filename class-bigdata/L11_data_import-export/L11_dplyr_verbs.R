library(tidyverse)
## we load the dataset
babynames = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L11_data_import-export/L11_dataset_babynames.rds"))

## have a look at the data
babynames


select(babynames, name, prop)


###################
# SELECT HELPERS
###################


### select range of columns

select(babynames, name:prop) #ranges: from/to

select(babynames, year:n)


### select except

select(babynames, -c(sex,n)) #for exclusion


### select with match

select(babynames, starts_with("n"))



###################
## FILTER
###################

filter(babynames, name == "Garrett") #boolean for condition (==)

filter(babynames, prop >= 0.08)

## filter extracts rows that meet every logical criteria

filter(babynames, name == "Garrett", year == 1880) #comma means here AND (both conditions met)


###################
## ARRANGE
###################


babynames %>% 
  arrange(n)


## inverting the order

babynames %>% 
  arrange(desc(n))


###################
## MAGIC FUNCTIONS
###################

## number of rows in a dataset or group
babynames %>% 
  summarise(n = n()) #counts all the values in a group

# number of DISTINCT values in a variable

babynames %>% 
  summarise(
    n = n(), 
    nname = n_distinct(name) #number of unique values
    )
ggplot(aes(x=base, y=counts))+
  geom_bar(stat = "identity")


babynames %>% 
  group_by(year) %>% 
  summarise(n_children = sum(n)) %>% 
        ggplot()+
 
  
  