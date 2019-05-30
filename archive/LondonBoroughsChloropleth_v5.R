install.packages(c("rgeos","maptools","gpclib", "viridis", "shadowtext"))
library(rgeos)
library(maptools)
library(gpclib)
library(rgdal)
library(ggplot2)
library(dplyr)
library(plyr)
library(viridis)
library(shadowtext)

fire.data.before <- read.csv("boroughs_before.csv")
fire.data.after <- read.csv("boroughs_after.csv")
fire.data.diff <- as.data.frame(c(fire.data.after[1],fire.data.after[2]-fire.data.before[2]))
write.csv(fire.data.diff, "boroughs_diff.csv")
fire.data.closed <- read.csv("closed_stations.csv")
closed.stations <- as.list(fire.data.closed[1])

London_Boroughs.shp <- readOGR(dsn = "./GISboundaries/ESRI", layer = "London_Borough_Excluding_MHW", stringsAsFactors = FALSE)
London_Boroughs.shp.df <- fortify(London_Boroughs.shp, region = "NAME")

boroughs_before.df <- merge(London_Boroughs.shp.df, fire.data.before, by ="id")
boroughs_after.df <- merge(London_Boroughs.shp.df, fire.data.after, by ="id")
boroughs_diff.df <- merge(London_Boroughs.shp.df, fire.data.diff, by ="id")
closed_boroughs.df <- merge(London_Boroughs.shp.df, fire.data.closed, by ="id")
borough_labels <- ddply(boroughs_before.df, .(id), summarize, lat = mean(lat), long = mean(long))
borough_labels_closed <- ddply(closed_boroughs.df, .(id), summarize, lat = mean(lat), long = mean(long))

# Chloropleth of attendance time BEFORE closures -----------------------------------------------------
map_before <- ggplot(data = boroughs_before.df, aes(x = long, y = lat, group = id))
map_before + 
  geom_polygon(aes(fill = time)
               #, color = 'black', size = 0.1
               ) +
  scale_fill_gradient(high = "#e34a33", low = "#fee8c8", guide = "colorbar") +
  coord_fixed(1.3) +
  theme(legend.justification=c(0,0), legend.position=c(0,0)) +
  geom_text(data = borough_labels, aes(x = long, y = lat, label = id), size = 2) +
  theme_void()

# Chloropleth of attendance time AFTER closures ------------------------------------------------------
map_after <- ggplot(data = boroughs_after.df, aes(x = long, y = lat, group = id))
map_after + 
  geom_polygon(aes(fill = time)) +
  scale_fill_gradient(high = "#e34a33", low = "#fee8c8", guide = "colorbar") +
  coord_fixed(1.3) +
  theme(legend.justification=c(0,0), legend.position=c(0,0)) +
  geom_text(data = borough_labels, aes(x = long, y = lat, label = id), size = 2) +
  theme_void()

# Chloropleth of attendance time diffs after closures ----------------------
map_diff <- ggplot(data = boroughs_diff.df, aes(x = long, y = lat, group = id))
borough_labels_excl_closed <- borough_labels[!(borough_labels$id %in% borough_labels_closed$id), c(1,2,3)]

timediff_map <- map_diff + 
                  geom_polygon(aes(fill = time)) +
                  theme_void() +
                  scale_fill_viridis(option = "cividis", breaks=c(-10,10,30,50), name="Change in mean \n attendance time",
                                     guide = guide_legend( keyheight = unit(1, units = "mm"), keywidth=unit(5, units = "mm"), 
                                     label.position = "bottom", title.position = 'top', nrow=1)) +
                  labs(
                    title = "Fire Brigade Attendance Time",
                    subtitle = "Difference between average first attendance time before and after 2014 station closures", 
                    caption = "Data: data.gov || map created by Adam Alnak"
                      ) +
                  theme(
                    plot.title = element_text(size= 11, hjust=0.01, colour = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
                    plot.subtitle = element_text(size= 8, hjust=0.012, colour = "#4e4d47", margin = margin(b = -0.1, t = 0.41, l = 2, unit = "cm")),
                    plot.caption = element_text(size=7, colour = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
                    legend.position = c(0.9, 0.09)
                      ) +
                  geom_shadowtext(data = borough_labels_excl_closed, aes(x=long, y=lat, label=id), colour="white", size=2.5) +
                  geom_shadowtext(data = borough_labels_closed, aes(x=long, y=lat, label=id), colour="coral", size=2.5)
ggsave("timediff_map.png", timediff_map, width=11, height=8.5)

#ggsave("Time_diffs.png")


# Chloropleth of poverty rates --------------------------------------------
poverty.data <- read.csv("poverty-rates-r.csv")
boroughs_poverty.df <- merge(London_Boroughs.shp.df, poverty.data, by ="id")
map_poverty <- ggplot(data = boroughs_poverty.df, aes(x = long, y = lat, group = id))

poverty_map <- map_poverty + 
                geom_polygon(aes(fill = PovertyRate)) +
                theme_void() +
                scale_fill_viridis(option = "cividis", breaks=c(0.20,0.25,0.3,0.35), name="Poverty Rates",
                                   guide = guide_legend( keyheight = unit(1, units = "mm"), keywidth=unit(5, units = "mm"), 
                                                         label.position = "bottom", title.position = 'top', nrow=1)) +
                labs(
                  title = "Proportion of Population Living in Poverty (after housing costs)",
                  subtitle = "Small area model-based households in poverty estimate for Engalnd and Wales, ONS. The data is for 2013/14.", 
                  caption = "Data: www.trustforlondon.org.uk/data || map created by Adam Alnak"
                ) +
                theme(
                  plot.title = element_text(size=11, hjust=0.01, colour="#4e4d47", margin=margin(b=-0.1, t=0.4, l=2, unit="cm")),
                  plot.subtitle = element_text(size=8, hjust=0.012, colour="#4e4d47", margin = margin(b=-0.1, t=0.41, l=2, unit="cm")),
                  plot.caption = element_text(size=7, colour="#4e4d47", margin=margin(b=0.3, r=-99, unit="cm") ),
                  legend.position = c(0.9, 0.09)
                ) +
                geom_shadowtext(data = borough_labels_excl_closed, aes(x=long, y=lat, label=id), colour="white", size=3) +
                geom_shadowtext(data = borough_labels_closed, aes(x=long, y=lat, label=id), colour="coral", size=3)