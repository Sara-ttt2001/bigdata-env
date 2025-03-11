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
