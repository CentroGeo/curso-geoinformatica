# arithemtic operations
2+2
4^2
# functions
sqrt(4)
sin(2)

# named arguments
seq(from=1, to=10, by=2)
seq(from=1, to=10, length=5)

# chaining
sqrt((sqrt(9))^2)

# assignment
temp <- 16
temp
dx <- 7
dy <- 9
dist <- sqrt(dx^2 + dy^2)
dist

# scope
sqrt(x = 16)
sqrt(x <- 16)

# vectors!
42
vec <- seq(from=1, to=10, by=2)
sqrt(vec)
vec2 <- c(3, 'hello', TRUE)

# sample datasets
data()
data(Seatbelts)
belts <- data.frame(Seatbelts)

# data frames
countries <- c('Germany', 'Netherlands', 'Colombia', 'Brazil', 'France')
scored <- c(18, 15, 12, 11, 10)
conceded <- c(4, 4, 4, 14, 3)

goalstats <- data.frame(countries, scored, conceded)
goalstats[1]
goalstats$countries
goalstats[2,]

# exploring datasets
summary(Seatbelts)
hist(belts$DriversKilled)

# your own functions
double <- function(x){ 
  result = x * 2; 
  return(result);
}
double(5)

# packages
install.packages("rgdal")
library(rgdal)

# help
help(plot)
?plot

# examples
example(plot)

# change wd
setwd("~/Downloads")
