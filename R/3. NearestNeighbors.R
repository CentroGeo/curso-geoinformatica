# check dirs
getwd()
setwd("~/R")

# clear workspace
rm(list = ls())

# load packages
library(rgdal)

# load datasets and list them
load("datasets.rdata")
ls()

# functions
km2d <- function(km) {
  out <- (km/1.852)/60
  return(out)
}

d2km <- function(d) {
  out <- d * 60 * 1.852
  return(out)
}

# read SHP
map <- readOGR("world.shp", "world")
# set CRS
proj4string(map) <- CRS("+proj=eqc +lon_0=90w")

summary(map)

# set up plot
par(mar = c(0, 0, 0, 0))
plot(map)

# polity dataset
polity <- read.csv("polity.csv")
# check columns
names(polity)

# merge this data to map using CCODE
map@data <- data.frame(map@data, polity[match(map@data$CCODE, polity$ccode), ])

# replace values
map$polity <- ifelse(map$polity == -66, NA, map$polity)
map$polity <- ifelse(map$polity == -77, NA, map$polity)
map$polity <- ifelse(map$polity == -88, NA, map$polity)

# use nice colors
library(RColorBrewer)
dem.palette <- colorRampPalette(c("red", "green"), space = "rgb")
spplot(map, "polity", col.regions = dem.palette(20), main = "Polity IV Democracy Scores (2008)",  sub = "More red = More authoritarian | More green = More democratic")

# get centroids
map_crd <- coordinates(map)
# add column names
colnames(map_crd) <- c("LONG", "LAT")

# load spatial dependency library
library(spdep)

# copy dataset
map_join <- map
# JOIN by CCODE
map_join@data <- data.frame(map@data, cities[match(map@data$MAP_CCODE, cities$MAP_CCODE), c(1, 4, 5)])
# make a copy
data <- map_join

# prepare lat and long columns
map_crd2 <- cbind(map_join$LONG, map_join$LAT)
# rename columns
colnames(map_crd2) <- c("LONG", "LAT")
# repeat for IDs
IDs <- map_join$MAP_CCODE
# replace missing capital coords with centroids
map_crd2[is.na(map_crd2)] <- map_crd[is.na(map_crd2)]

# convert polygons to neighbor list
W_cont <- poly2nb(data, queen = TRUE)
# convert neighbors listt to weights list
W_cont_mat <- nb2listw(W_cont, style = "W", zero.policy = TRUE)

# use 500km as snapping distance
W_cont_s <- poly2nb(data, queen = TRUE, snap = km2d(500))
W_cont_s_mat <- nb2listw(W_cont_s, style = "W", zero.policy = TRUE)

# set up plot area
par(mfrow = c(1, 2), mar = c(0, 0, 1, 0))
# plot countries
plot(data, border = "grey")
# plot neighbor links
plot(W_cont_mat, coords = map_crd, pch = 19, cex = 0.1, col = "blue", add = TRUE)
title("Direct Contiguity")
# second plot
plot(data, border = "grey")
plot(W_cont_s_mat, coords = map_crd, pch = 19, cex = 0.1, col = "blue", add = TRUE)
title("Contiguity + 500km")

# KNN, k=1 for countries
W_knn1 <- knn2nb(knearneigh(map_crd, k = 1, RANN = FALSE), row.names = IDs)
W_knn1_mat <- nb2listw(W_knn1)
# KNN, k=1 for capital cities
W_knn1_2 <- knn2nb(knearneigh(map_crd2, k = 1, RANN = FALSE), row.names = IDs)
W_knn1_mat_2 <- nb2listw(W_knn1_2)

# set up plot area for centroids
par(mfrow = c(1, 2), mar = c(0, 0, 1, 0))
# plot
plot(data, border = "grey")
plot(W_knn1_mat, coords = map_crd, pch = 19, cex = 0.1, col = "blue", add = TRUE)
title("k=1 (Centroids)")

# set up plot area for capitals
plot(data, border = "grey")
plot(W_knn1_mat_2, coords = map_crd2, pch = 19, cex = 0.1, col = "blue", add = TRUE)
title("k=1 (Capitals)")


# spatial operators
# clear all
rm(list = ls())

# if not loaded,load packages
library(rgeos)
# points and polygons
pt1 = readWKT("POINT(0.5 0.5)")
pt2 = readWKT("POINT(2 2)")
p1 = readWKT("POLYGON((0 0,1 0,1 1,0 1,0 0))")
p2 = readWKT("POLYGON((2 0,3 1,4 0,2 0))")

#par(mar = c(0, 0, 0, 0))
plot(p1)
plot(p2, add=TRUE)
plot(pt1, add=TRUE)
plot(p2)
plot(pt2, add=TRUE)

# distances
gDistance(pt1,pt2)
gDistance(p1,pt1)
gDistance(p1,pt2)
gDistance(p1,p2)

# buffers
buffer <- gBuffer(p2, width=1)
plot(buffer)
plot(p2, add=TRUE)
