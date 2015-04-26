library(RCurl)
library(raster)
library(spatstat)
library(sp)
library(bitops)

getStateShape <- function() {
    
}

# determine the extents of the user-selected state
# ie - how far east, west, north, and south the state 
# goes so we know how much data to download
# #################################################
findExtents <- function(x) {
    # minx, maxx, miny, maxy
    bbox <- data.frame(minx=NA, maxx=NA, miny=NA, maxy=NA)
    
    # get number of polygons in the given SpatialPolygons-class x
    L <- length(x@Polygons)
        
    # loop through polygons in SpatialPolygons-class and determine bounding box coordinates
    for (i in 1:L) {
        if (is.na(bbox$minx) || bbox$minx > min(x@Polygons[[i]]@coords[,1])) bbox$minx <- min(x@Polygons[[i]]@coords[,1])
        if (is.na(bbox$miny) || bbox$miny > min(x@Polygons[[i]]@coords[,2])) bbox$miny <- min(x@Polygons[[i]]@coords[,2])
        if (is.na(bbox$maxx) || bbox$maxx < max(x@Polygons[[i]]@coords[,1])) bbox$maxx <- max(x@Polygons[[i]]@coords[,1])
        if (is.na(bbox$maxy) || bbox$maxy < max(x@Polygons[[i]]@coords[,2])) bbox$maxy <- max(x@Polygons[[i]]@coords[,2])
    }        
    
    # expand bounding box of state by 25% - padding for our map extents
    t <- data.frame(minx=NA, maxx=NA, miny=NA, maxy=NA)
    t$minx <- bbox$minx - 0.125 * (bbox$maxx - bbox$minx)
    t$maxx <- bbox$maxx + 0.125 * (bbox$maxx - bbox$minx)
    t$miny <- bbox$miny - 0.125 * (bbox$maxy - bbox$miny)
    t$maxy <- bbox$maxy + 0.125 * (bbox$maxy - bbox$miny)
    
    t
}

getSSData <- function(b, m) {
    # contact topography/gravity host
    url <- "http://topex.ucsd.edu/cgi-bin/get_data.cgi"
    getURL(url)
    
    # get & clean data
    ts <- postForm(url, north=b$maxy, west=b$minx, east=b$maxx, south=b$miny, mag=m)
    t <- read.delim(textConnection(ts),header=FALSE,sep="",strip.white=TRUE)
    
    if (m == 1) {
        names(t) <- c("Lon", "Lat", "DEM")
    } else {
        names(t) <- c("Lon", "Lat", "FAA")
    }

    t$Lon <- ifelse(t$Lon > 180, t$Lon - 360, t$Lon)
    
    t
}

plotData <- function(hill, data, shp) {
    plot(hill, legend=FALSE, col=grey(0:100/100))
    plot(data, add=TRUE, alpha=0.65)
    contour(data, add=TRUE, col=rgb(0,0,0,alpha=0.15))
    plot(shp, add=TRUE, lwd=2.5)
}

