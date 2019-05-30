install.packages(c("rgeos","maptools","gpclib"))
library(rgeos)
library(maptools)
library(gpclib)  # may be needed, may not be
library(rgdal)
library(ggplot2)
library(dplyr)
library(plyr)

London_Borough.shp <- readOGR(dsn = "./GISboundaries/ESRI", 
                      layer = "London_Borough_Excluding_MHW", stringsAsFactors = FALSE)
#plot(London_Borough.shp)

London_Borough.shp.df <- fortify(London_Borough.shp, 
                         region = "NAME")

map <- ggplot(data = London_Borough.shp.df, 
       aes(x = long, y = lat, group = group))
#map + geom_path()

#London_Borough.shp.df %>% 
#  distinct(id) %>% 
#  write.csv("boroughs.csv", row.names = FALSE)

fire.data.before <- read.csv("boroughs_before.csv")
fire.data.after <- read.csv("boroughs_after.csv")
fire.data.change <- read.csv("boroughs_change.csv")
#colwise(class)(fire.data.before)
#colnames(fire.data.before) <- c("id","time")
London_Borough_before.shp.df <- merge(London_Borough.shp.df, fire.data.before, by ="id")
London_Borough_after.shp.df <- merge(London_Borough.shp.df, fire.data.after, by ="id")
London_Borough_change.shp.df <- merge(London_Borough.shp.df, fire.data.change, by ="id")


#map <- ggplot(data = London_Borough.shp.df, 
#       aes(x = long, y = lat, group = id))

theme_bare <- theme(
  axis.line = element_blank(), 
  axis.text.x = element_blank(), 
  axis.text.y = element_blank(),
  axis.ticks = element_blank(), 
  axis.title.x = element_blank(), 
  axis.title.y = element_blank(),
  legend.text=element_text(size=7),
  legend.title=element_text(size=8),
  panel.background = element_blank(),
  panel.border = element_rect(colour = "gray", fill=NA, size=0.5)
)

boroughs <- ddply(London_Borough.shp.df, .(id), summarize, lat = mean(lat), long = mean(long), time=mean(time))

map + 
  geom_polygon(aes(fill = time), color = 'gray', size = 0.1) +
  scale_fill_gradient(high = "#e34a33", low = "#fee8c8", guide = "colorbar") +
  coord_fixed(1.3) +
  theme(legend.justification=c(0,0), legend.position=c(0,0)) +
  geom_text(data = boroughs, aes(x = long, y = lat, label = id), size = 2) +
  theme_bare
