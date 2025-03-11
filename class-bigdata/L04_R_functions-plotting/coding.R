numbers_list <- list(
  c(1,2,3,4,5),
  c(10,20,30,40),
  c(100,200,250,300)
)
numbers_list
#solution 1
for (vector in numbers_list){
  res <- mean(vector)
  print(res)
}

#solution 2
lapply(numbers_list, function(x) mean(x))
lapply(numbers_list, mean)

#solution 3
mean(numbers_list[[1]]) #one way

nums <- numbers_list[[1]] #second way
mean(nums)
#very basic one, we can use 1:length(numbers_list)
for (index in 1:3){
  num_vec <- numbers_list [[index]]
  calc <- mean(num_vec)
  print(calc)
}




### the average of a vector is calculated with the function: mean(x)
### use the list: numbers_list
### and calculate the average of each of the three vectors by using 3 methods
### a for loop using an index instead of a variable assignment
### a for loop using a variable assignment
### an l-apply function

numbers_list <- list(
  c(1,2,3,4,5),
  c(10,20,30,40),
  c(100,200,250,300)
)
numbers_list



avg1 = unlist(
  lapply(numbers_list , mean)
)
avg1

avg2 = lapply(numbers_list , function(x) mean(x))
avg2

### a for loop using an index instead of a variable assignment
numbers_list <- list(
  c(1,2,3,4,5),
  c(10,20,30,40),
  c(100,200,250,300)
)
numbers_list

num_elements = length(numbers_list)
for (index in 1:num_elements){ #number of vectors in the list
  val = mean(numbers_list[[index]])
  print (val)
}

res2 = mean(numbers_list[[2]])
res2


### a for loop using a variable assignment


for (index in numbers_list){
result = mean(index)
print(result)
}

#define a function

phrase = function(first_name , last_name){
  write = paste0(first_name," ",last_name)
  return(write) #always remember to return the variable we are performing the function on
}

phrase("sara","altamam")


