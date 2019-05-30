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
write.csv(fire.data.change, "boroughs_change.csv")
fire.data.closed <- read.csv("closed_stations.csv")
closed.stations <- as.list(fire.data.closed[1])

London_Boroughs.shp <- readOGR(dsn = "./GISboundaries/ESRI", layer = "London_Borough_Excluding_MHW", stringsAsFactors = FALSE)
London_Boroughs.shp.df <- fortify(London_Boroughs.shp, region = "NAME")

boroughs_before.df <- merge(London_Boroughs.shp.df, fire.data.before, by ="id")
boroughs_after.df <- merge(London_Boroughs.shp.df, fire.data.after, by ="id")
boroughs_change.df <- merge(London_Boroughs.shp.df, fire.data.change, by ="id")
closed_boroughs.df <- merge(London_Boroughs.shp.df, fire.data.closed, by ="id")

# Map showing attendance time BEFORE closures -----------------------------------------------------
map_before <- ggplot(data = boroughs_before.df, aes(x = long, y = lat, group = id))
boroughs_before <- ddply(boroughs_before.df, .(id), summarize, lat = mean(lat), long = mean(long))
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
boroughs_after <- ddply(boroughs_after.df, .(id), summarize, lat = mean(lat), long = mean(long))
map_after + 
  geom_polygon(aes(fill = time)) +
  scale_fill_gradient(high = "#e34a33", low = "#fee8c8", guide = "colorbar") +
  coord_fixed(1.3) +
  theme(legend.justification=c(0,0), legend.position=c(0,0)) +
  geom_text(data = boroughs_after, aes(x = long, y = lat, label = id), size = 2) +
  theme_void()

# Map showing attendance time changes after closures ----------------------
map_change <- ggplot(data = boroughs_change.df, aes(x = long, y = lat, group = id))
closed_boroughs <- ddply(closed_boroughs.df, .(id), summarize, lat = mean(lat), long = mean(long))
boroughs_change <- ddply(boroughs_change.df, .(id), summarize, lat = mean(lat), long = mean(long))
boroughs_change <- boroughs_change[!(boroughs_change$id %in% closed_boroughs$id), c(1,2,3)]

map_change + 
  geom_polygon(aes(fill = time)) +
  theme_void() +
  scale_fill_viridis(option = "cividis", breaks=c(-10,10,30,50), name="Change in time",
                     guide = guide_legend( keyheight = unit(1, units = "mm"), keywidth=unit(5, units = "mm"), 
                     label.position = "bottom", title.position = 'top', nrow=1)) +
  labs(
    title = "Fire Brigade Attendance Time",
    subtitle = "Difference between average first attendance time before and after 2014 station closures", 
    caption = "Data: data.gov / created by Adam Alnak"
  ) +
  theme(
    plot.title = element_text(size= 11, hjust=0.01, colour = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 8, hjust=0.012, colour = "#4e4d47", margin = margin(b = -0.1, t = 0.41, l = 2, unit = "cm")),
    plot.caption = element_text(size=7, colour = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    legend.position = c(0.9, 0.09)
  ) +
  
  #theme(legend.justification=c(0,0), legend.position=c(0,0)) +
  geom_text(data = boroughs_change, aes(x = long, y = lat, label = id), size = 2) +
  geom_text(data = closed_boroughs, aes(x = long, y = lat, label = id, colour = "red"), size = 3)
  

#ggsave("Time_changes.png")
