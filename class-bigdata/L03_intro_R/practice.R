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

product = pepsi[1,2] * cola[2,1]
product

name = c("sara")
lastname = c("al tamam")
fullname = paste(name , lastname , sep = "-")
fullname
