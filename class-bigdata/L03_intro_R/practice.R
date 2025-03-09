a = 1
b <- 2
c = a + b
c

sara = c(30,30,30)
ammar = c(2,3,7)

total = sara[1] + ammar[3]
total
sara[1]
print(total)
sara[c(1,2,3)]

hushhush = list(
  first = c(23,56,79,147),
  second = c("SARA","AMMAR","AUM"),
  third = c(984,1024,57)
)

store_first = hushhush[[1]] #store_first is now a vector that is not within the list 
store_first
print(store_first[3])

store_third = hushhush[[3]]
store_third

sum = store_first[3] + store_third[2]
sum


pepsi = matrix(c(678,456,903,345), ncol = 2, byrow = 2)
cola = matrix(c(76,54,90,99), ncol = 2, byrow = 2)
pepsi
cola
print(cola)

product = pepsi[1,2] * cola[2,1]
product

name = c("sara")
lastname = c("al tamam")
fullname = paste(name , lastname , sep = "-")
fullname
print(fullname)

formula1 = data.frame(
  driver_name = c("carlos", "russel","leclerc","alonso"),
  age = c(31 , 27 , 29 , 45),
  team = c("williams","mercedes","ferrari","aston martin")
)
formula1
formula1[["driver_name"]]
formula1$driver_name
formula1["driver_name"]

res_a <- data.frame(
  sample = c("sample1", "sample2", "sample3"),
  measure = c(123, 234, 345)
)


res_a
rownames(res_a) = c("exp1","exp2","exp3")

res_a

library(tidyverse)
tib_sara = as_tibble(formula1)
tib_sara


tib_ammar = tibble(
  lifestyle = c('eat','sleep',"fuck",'sleep'),
  category = c('good','bad','perfect','good')
)
tib_ammar

tib_ammar %>% 
  mutate(lifestyle = gsub('sleep','work',lifestyle)) #first, we put the value we want to change, then we put the new value, then the name of the variable in which the value will be saved in.
tib_ammarupdate = tib_ammar %>% mutate(lifestyle = gsub('sleep','work',lifestyle))
tib_ammarupdate

tib_practice = tibble(
  ournames = c("sara","ammar","dana","majali","hussain"),
  eyecolor = c("green lantern","poopy diahheria","brown","hazel","fa7meh"),
  haircolor = c("blondie","trump","blondie","brown","coal")
  )
tib_practice

tib_practice %>% 
  group_by(haircolor)

tib_practice %>% 
  group_by(haircolor) %>% 
  mutate(types = n())

tib_practice %>% 
  group_by(haircolor) %>% 
  summarise(types = n())
