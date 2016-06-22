# install packages and dependencies
install.packages(c("sp", "rgdal", "ggplot2", "ggmap","spdep", "spatstat", "rgeos", "maptools"))
# load packages
library(sp)
library( rgdal)

# check dirs
getwd()
setwd("~/R")

# load data
cycle <- read.csv("London_cycle_hire_locs.csv", header = TRUE)
# inspect
head(cycle)
# plot with coordinates
plot(cycle$X,cycle$Y)
class(cycle)
# tell R about geo coords
coordinates(cycle) <- c("X", "Y")
# check data structure
str(cycle)
?str

# CRS
# rgdal required!
EPSG <- make_EPSG()
head(EPSG)
with(EPSG, EPSG[grep("British National", note), ])
BNG<-CRS("+init=epsg:27700")
proj4string(cycle) = BNG

# using SHP files
# load
sport <- readOGR("london_sport.shp", layer = "london_sport")
# check CRS code
sport@proj4string
# different plots
plot(sport)
plot(sport, col = "blue")
plot(cycle, add = T, col = "red", pch = "o")

# write SHP
writeOGR(cycle, "cycle.shp", layer = "cycle", driver = "ESRI Shapefile")

# maps with ggplot
# load packages
library(ggplot2)
library(rgeos)
library(maptools)

# attr table headers of SHP
names(sport)

# a scatter plot
# create plot
p <- ggplot(sport@data, aes(Partic_Per, Pop_2001))
# actually plot it
p + geom_point()
# modify it
p + geom_point(colour = "red", size = 2)
# style it with variables
p + geom_point(aes(colour = Partic_Per, size = Pop_2001))
# labels
p + geom_point(aes(colour = Partic_Per, size = Pop_2001)) + geom_text(size = 5, aes(label = name))

# convert polygons to data frames
sport_geom <- fortify(sport, region = "ons_label")
# add data back
sport_geom <- merge(sport_geom, sport@data, by.x = "id", by.y = "ons_label")
# define map
map <- ggplot(sport_geom, aes(long, lat, group = group, fill = Partic_Per)) + geom_polygon() + coord_equal() + labs(x = "Easting (m)", y = "Northing (m)", fill = "% SportPartic.") + ggtitle("London Sports Participation")
# show map
map
# colors
map + scale_fill_gradient(low = "white", high = "black")

# export
ggsave("my_map.pdf")
ggsave("my_map.png")
ggsave("my_large_map.png", scale = 3, dpi = 400)

# descriptive stats w/ ggplot
# load data
input <- read.csv("ambulance_assault.csv")
head(input)
# ggplot object
p_ass <- ggplot(input, aes(x = assault_09_11))
# plot
p_ass + geom_histogram()
#style
p_ass + geom_histogram(binwidth = 10, fill = "steelblue") + geom_density(fill = NA, colour = "black")
# histogram + density
p2_ass = ggplot(input, aes(x = assault_09_11, y = ..density..))
p2_ass + geom_histogram(fill = "steelblue") + geom_density(fill = "red", alpha = 0.3)

# outliers
input[which(input$assault_09_11 > 750), ]
p3_ass <- ggplot(input, aes(x = Bor_Code, y = assault_09_11))
p3_ass + geom_boxplot()
p3_ass + geom_boxplot() + coord_flip()

# facet wrap
p_ass + geom_histogram() + facet_wrap(~Bor_Code)

# faceted maps
# install and load package
install.packages("reshape")
library(reshape)

# load data
london.data <- read.csv("census-historic-population-borough.csv")
# melt data: move columns into rows
london.data.melt <- melt(london.data, id = c("Area.Code", "Area.Name"))
# merge geometries
plot.data <- merge(sport_geom, london.data.melt, by.x = "id", by.y = "Area.Code")
# display
ggplot(data = plot.data, aes(x = long, y = lat, fill = value, group = group)) + geom_polygon() + geom_path(colour = "grey", lwd = 0.1) + coord_equal() + facet_wrap(~variable)

# base maps
# load packages
library(ggmap)
library(mapproj)
# get area
map <- get_map(location = "Europe", zoom = 4)
# plot
ggmap(map)

#Overlay data and basemap

London.Google <- spTransform(sport, CRS("+proj=longlat +datum=WGS84"))
London.Google <- fortify(London.Google, region = "ons_label")
London.Google <- merge(London.Google, sport@data, by.x = "id", by.y = "ons_label")

ggmap(LondonLoc) + geom_polygon(aes(x=long, y=lat, group=group, fill=Partic_Per, colour=Partic_Per), size=1,color='blue', data=London.Google, alpha=0.5) + scale_fill_gradient(low='red', high='green')
