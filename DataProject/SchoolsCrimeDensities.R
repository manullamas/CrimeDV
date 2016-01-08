
library(rmongodb)
library(dplyr)
# Creating mongo connection
createMongo <- function() {
  if (exists("mongo")) {
    try(mongo.destroy(mongo))
  }
  mongo <<- mongo.create(host = "mongodb-dse662l3.cloudapp.net:27017", db = DB)
  return(mongo.is.connected(mongo))
}
createMongo()

# Calculate distance between two points
distance <- function(lat1, long1, lat2, long2) {
  
  # Convert arguments to radians
  lat1 = pi * lat1 / 180
  lat2 = pi * lat2 / 180
  long1 = pi * long1 / 180
  long2 = pi * long2 / 180
  
  # Calculates distance using
  a <- sin( (lat1 - lat2)/2 ) ^ 2 + cos(lat1)*cos(lat2)* sin( (long1 - long2)/2 ) ^ 2
  c = 2 * atan2( sqrt(a), sqrt(1 - a))
  d = 6371 * c
  return(d)
}

distRad <- function(lat1, long1, lat2, long2) {
  a <- (lat1 - lat2) ^ 2 + (long2 - long1) ^ 2   
  return(a)
}


# crime densities in areas surrounding schools, chosen radium=0.3km
crimeDensities <- function(crimes, school, crimeType) { 
  if (length(crimes) == 0) { return(
    list(crimesInCircle = 0, crimeDensity = 0))
  }
  t10 <- Sys.time()
  crimesCircle <- length(crimes)
  crimeDensity <- crimesCircle / area

  createMongo()

  return(list(crimesInCircle = crimesCircle, crimeDensity = crimeDensity))
  t13 <- Sys.time()
  
  print(paste("density: list made,", t13-t12))
  
}   

createMongo()
# Download borough area sizes
boroughSizes <- mongo.find.all(mongo, "DSproject.boroughs", data.frame = TRUE)
# Download list of schools
schools <- mongo.find.all(mongo, "DSproject.secSchoolsLond")

MAX_DIST <- 0.3
AREA <- pi * (MAX_DIST/2)^2
SIG_NORM <- 0.2
area <- 0


sapply(1:679, function(index){
  area <<- AREA
  school <- schools[[index]]
  
  # Check if there is another school overlapping the cirlce but not take this into account if the schools are in the same precise location (will be counted as one in the visualization)
      if (school[["NearestSchoolDist"]] < MAX_DIST*2 & school[["NearestSchoolDist"]] > 0.00001) {
          d <- school[["NearestSchoolDist"]]
          r <- MAX_DIST
          overlap <- 2 * r^2 * acos(d/(2*r)) - (d/2) * sqrt(4*r^2 - d^2)
          area <<- AREA - overlap/2
          }
  
  ## query all the crimes inside the circle 
  t0 <- Sys.time()
  print( paste("school:", schools[[index]]["School"]))
  createMongo()
  query <- sprintf('{ "School": "%s"}', school[["School"]])
  crimes <- mongo.find.all(mongo, "DSproject.londonCrime6", query)
  totals <-  c(crimeType = "Totals", crimeDensities(crimes,school))
  crimeTypes <- mongo.distinct(mongo, "DSproject.londonCrime6", "Crimetype")
  
  densities <- sapply(crimeTypes, function(crimetype) {
    print( crimetype )
    query <- sprintf('{ "School": "%s",  "Crimetype": "%s"}',
                     school[["School"]], crimetype)

    crimes <- mongo.find.all(mongo, "DSproject.londonCrime6", query)
    row <- c(crimetype, crimeDensities(crimes, school, crimetype))
  })
  densities <- t(cbind(totals, densities))

  ###  update queries
  createMongo()
  query <- sprintf( '{ "School": "%s" }', school[["School"]] )
  update <- list( "$set" = list( "Count" = densities[,2], "Crime Density" = densities[,3]))
  mongo.update(mongo, "DSproject.secSchoolsLond", query, update)

  print(paste(school[["School"]], Sys.time()))
})