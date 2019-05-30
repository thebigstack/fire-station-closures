install.packages(c("rgeos","maptools","gpclib", "viridis"))
library(rgeos)
library(maptools)
library(gpclib)
library(rgdal)
library(ggplot2)
library(dplyr)
library(plyr)
library(viridis)

fire.data.before <- read.csv("boroughs_before.csv")
fire.data.after <- read.csv("boroughs_after.csv")
fire.data.change <- as.data.frame(c(fire.data.after[1],fire.data.after[2]-fire.data.before[2]))

London_Boroughs.shp <- readOGR(dsn = "./GISboundaries/ESRI", layer = "London_Borough_Excluding_MHW", stringsAsFactors = FALSE)
London_Boroughs.shp.df <- fortify(London_Boroughs.shp, region = "NAME")

boroughs_before.df <- merge(London_Boroughs.shp.df, fire.data.before, by ="id")
boroughs_after.df <- merge(London_Boroughs.shp.df, fire.data.after, by ="id")
boroughs_change.df <- merge(London_Boroughs.shp.df, fire.data.change, by ="id")

# Map showing attendance time BEFORE closures -----------------------------------------------------
map_before <- ggplot(data = boroughs_before.df, aes(x = long, y = lat, group = id))
boroughs_before <- ddply(boroughs_before.df, .(id), summarize, lat = mean(lat), long = mean(long), time=mean(time))
map_before + 
  geom_polygon(aes(fill = time)
               #, color = 'black', size = 0.1
               ) +
  scale_fill_gradient(high = "#e34a33", low = "#fee8c8", guide = "colorbar") +
  coord_fixed(1.3) +
  theme(legend.justification=c(0,0), legend.position=c(0,0)) +
  geom_text(data = boroughs_before, aes(x = long, y = lat, label = id), size = 2) +
  theme_void()

# Map showing attendance time AFTER closures ------------------------------------------------------
map_after <- ggplot(data = boroughs_after.df, aes(x = long, y = lat, group = id))
boroughs_after <- ddply(boroughs_after.df, .(id), summarize, lat = mean(lat), long = mean(long), time=mean(time))
map_after + 
  geom_polygon(aes(fill = time)) +
  scale_fill_gradient(high = "#e34a33", low = "#fee8c8", guide = "colorbar") +
  coord_fixed(1.3) +
  theme(legend.justification=c(0,0), legend.position=c(0,0)) +
  geom_text(data = boroughs_after, aes(x = long, y = lat, label = id), size = 2) +
  theme_void()

# Map showing attendance time changes after closures ----------------------
map_change <- ggplot(data = boroughs_change.df, aes(x = long, y = lat, group = id))
boroughs_change <- ddply(boroughs_change.df, .(id), summarize, lat = mean(lat), long = mean(long), time=mean(time))
map_change + 
  geom_polygon(aes(fill = time)) +
  coord_fixed(1.3) +
  theme(legend.justification=c(0,0), legend.position=c(0,0)) +
  scale_fill_viridis(option = "cividis", breaks=c(-10,10,30,50), 
                     name="Change in Time", guide = guide_legend( keyheight = unit(1, units = "mm"), 
                     keywidth=unit(4, units = "mm"), label.position = "bottom", title.position = 'top', nrow=1) ) +
    geom_text(data = boroughs_change, aes(x = long, y = lat, label = id), size = 2) +
  theme_void()

#ggsave("Time_changes.png")
