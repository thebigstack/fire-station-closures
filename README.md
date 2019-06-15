# What has been the impact of the 2014 London fire station closures?

In 2014 ten London fire stations were shut down to make savings against the fire service budget. 552 firefighter jobs were cut and the number of fire engines in the city reduced by 14. This projects attempts to quantify some of the impact arising from the closures.

## Methodology

London fire and rescue service data was obtained from the [London Datastore](https://data.london.gov.uk/dataset/london-fire-brigade-incident-records). 

London poverty data was obtained from the [Trust for London](https://www.trustforlondon.org.uk/data/poverty-borough/)

Geo data to create a map of London was obtained from the [London Borough of Barnet Greater London Authority](https://data.gov.uk/dataset/e6b9d1c6-7c34-42ca-a100-cd62164ea76c/london-fire-brigade-incident-records).

The FRS data was analysed and cleaned prior to use in this project. It was then visualised with choropleths (map charts) showing how the closures affected different parts of the city.

![Fire Brigade Attendance Time](/timediff_map.png)

Boroughs are shaded yellow for the largest increases in mean first attendance time to blue for negligible changes or improvements in attendance time. The boroughs with orange text have been highlighted because they are those which contained stations which were closed in 2014. The areas with the most increased attendance times are those located around the closed stations. This confirms that the fears of reduced coverage by affected councils prior to the closures were well founded. Londoners living or working in the areas neighbouring the closed stations are more likely to suffer from a slow response time if they are involved in an incident.

The next visualisation looks at *who* is being affected by comparing the FRS data with data from the Trust For London who are a charity focused on tackling poverty and inequality in London. Their “Poverty by London Local Authority” data which is taken from the Office for National Statistics gives the proportion of population living in poverty (after housing costs). 

![Proportion of Population Living in Poverty](/poverty_map.png)

At first glance it seems to have similarities with the choropleth of boroughs most impacted by the station closures. The more impoverished boroughs are again within inner and east London. Assuming the regions with larger time differences map to those with higher rates of poverty, the only major differences from what we would expect to see on the poverty map is less poverty in Barking and Dagenham, Southwark and Lewisham, and more in Brent and Haringey which are geographically the largest boroughs in inner London.

A full list of boroughs with ranked poverty rates is available in "changes_poverty.xlsx".

Ranking the data and sorting by poverty rate shows each of the 9 boroughs with most adversely increased attendance times after the closures have poverty rates at the median or higher. The two most impoverished boroughs (Tower Hamlets and Newham) are both in the five which saw the biggest increase in attendance times. **All of the boroughs most badly impacted by the closures are in the poorest half of the city**.

We can also see that 3 of the 6 boroughs that saw an improved attendance time (Richmond, Bromley and Sutton) are also the top 3 least impoverished boroughs. A fourth, Kingston is the 7th least impoverished borough. In fact, every single one of the 6 boroughs that saw a decreased attendance time had poverty rates at least 3% lower than the median. Note that this is not a comparison of the overall efficacy of the fire services in these areas. It is a comparison of the impact of the station closures on these areas. **The areas which have actually benefitted from the closures are amongst those with the lowest poverty rates in the capital and no borough with high poverty rates saw a decrease in average attendance time**.


## How statistically significant are these results?

While there is a clear visual similarity between the two choropleths, is it possible to show a correlation by statistical measures?

Spearman’s rank correlation coefficient (ρ) has been calculated using the ranked lists of poverty rate and change in attendance time. This gives a value of 0.53 which is close to the Pearson correlation coefficient of 0.55. These figures suggest moderate correlation between poverty rate and impact of the fire station closures. The p-value for ρ is 0.0015 which means that the probability of finding the observed, or more extreme, results if there was no correlation is very low, and indeed well below the significance threshold of α = 0.01. If there was no correlation between the two sets of data, we would expect to see similar results only about 1.5 times in a thousand. The full calculations for these results as well as a scatterplot showing borough poverty rate against change in attendance time is available in the “changes_poverty.xlsx” spreadsheet.
It is important to note that correlation does not prove causation and it is not the intention of this report to suggest that higher rates of poverty have in any way caused the larger increases in attendance time. However, **the data shows categorically that in the selected two-year period after the station closures, poorer citizens disproportionately suffered from deteriorating fire service response times**.



## Create the choropleths for yourself

Simply copy the repo and run through the code in LondonBoroughsChoropleth.R. 

### Prerequisites

All you need on your computer to run this project is R and RStudio. The code was built with R version 3.5.3. 

### Set up

The packages this project uses are installed here

```
install.packages(c("rgeos","maptools","gpclib", "viridis", "shadowtext"
                   ,"rgdal", "ggplot2", "dplyr", "plyr", "viridis") )
```

They are loaded like this

```
library(plyr)
library(dplyr)
library(ggplot2)
library(rgeos)
library(maptools)
library(gpclib)
library(rgdal)
library(viridis)
library(shadowtext)
```
Together they provide functionality to process the data and geo shape files and to create the visualisations.

### Processing the FRS data in R

```
fire.data.before <- read.csv("input/boroughs_before.csv")
fire.data.after <- read.csv("input/boroughs_after.csv")
fire.data.diff <- as.data.frame(c(fire.data.after[1],fire.data.after[2]-fire.data.before[2]))
write.csv(fire.data.diff, "input/boroughs_diff.csv")
fire.data.closed <- read.csv("input/closed_stations.csv")
closed.stations <- as.list(fire.data.closed[1])
```
### Processing the geo data in R

```
London_Boroughs.shp <- readOGR(dsn = "./GISboundaries/ESRI", layer = "London_Borough_Excluding_MHW", stringsAsFactors = FALSE)
London_Boroughs.shp.df <- fortify(London_Boroughs.shp, region = "NAME")

boroughs_before.df <- merge(London_Boroughs.shp.df, fire.data.before, by ="id")
boroughs_after.df <- merge(London_Boroughs.shp.df, fire.data.after, by ="id")
boroughs_diff.df <- merge(London_Boroughs.shp.df, fire.data.diff, by ="id")
closed_boroughs.df <- merge(London_Boroughs.shp.df, fire.data.closed, by ="id")
borough_labels <- ddply(boroughs_before.df, .(id), summarize, lat = mean(lat), long = mean(long))
borough_labels_closed <- ddply(closed_boroughs.df, .(id), summarize, lat = mean(lat), long = mean(long))
```

### Visualisation

There is code to create three choropleths from the FRS data: showing attendance time before and after the station closures, and the difference in attendance time. The latter is what is shown below.

### Poverty Data

The same process is followed to create a choropleth of poverty rates.


## Acknowledgements

My code was adapted from the great tutorials below.

Yan Holtz - [CHOROPLETH MAP FROM GEOJSON WITH GGPLOT2](https://www.r-graph-gallery.com/327-chloropleth-map-from-geojson-with-ggplot2/)

Anjesh Tuladhar - [Step-by-Step Choropleth Map in R: A case of mapping Nepal](https://medium.com/@anjesh/step-by-step-choropleth-map-in-r-a-case-of-mapping-nepal-7f62a84078d9)
