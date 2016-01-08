
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




    # delete schools with 0 distance (or use only one of them)

# CrimeDensities function calculates a list of the different measures of crime densities for a subset of crimes
# If the subset is a crimetype then this will be factored into the borough crime density value. 
crimeDensities <- function(crimes, school, crimeType) { 
  if (length(crimes) == 0) { return(
    list(crimesInCircle = 0, crimeDensity = 0, crimeDensityGaussian = 0,
         crimeDensityVsBorough = 0, crimeDensityVsBoroughGaussian = 0))
  }
  crimesCircle <- length(crimes)
  crimeDensity <- crimesCircle / area
  # Calculate Gaussian Density
  gaussWeights <- sapply(crimes, function(x) { 
    dnorm(x[["SchoolDistance"]])
  })
  crimeDensityG <- sum(gaussWeights) / area
  
  # Borough normalised
  createMongo()
  query <- sprintf( '{ "LocalAuthority": "%s" }', school[["Borough"]])
  boroughCrimeDensity <- mongo.count(mongo, "DSproject.londonCrime6", query) / boroughSizes[boroughSizes$boroughs == school[["Borough"]], "AreaKm"]
  crimeDensityVsBorough <- crimeDensity / boroughCrimeDensity
  crimeDensityVsBoroughG <- crimeDensityG / boroughCrimeDensity
  
  return(list(crimesInCircle = crimesCircle, crimeDensity = crimeDensity, crimeDensityGaussian = crimeDensityG,
              crimeDensityVsBorough = crimeDensityVsBorough, crimeDensityVsBoroughGaussian = crimeDensityVsBoroughG))
}   

createMongo()
# Download borough area sizes
boroughSizes <- mongo.find.all(mongo, "DSproject.boroughs", data.frame = TRUE)
# Download list of schools
schools <- mongo.find.all(mongo, "DSproject.secSchoolsLond")

# Calculate area of circle
MAX_DIST <- 0.3
AREA <- pi * (MAX_DIST/2)^2
SIG_NORM <- 0.2
area <- 0


# loop through each school
sapply(3:679, function(index){
  area <<- AREA
  school <- schools[[index]]
  
  #### Calculate Area ----
  # Check if there is another school overlapping the cirlce
      if (school[["NearestSchoolDist"]] < MAX_DIST*2 & school[["NearestSchoolDist"]] > 0.00001) {
          d <- school[["NearestSchoolDist"]]
          r <- MAX_DIST
          overlap <- 2 * r^2 * acos(d/(2*r)) - (d/2) * sqrt(4*r^2 - d^2)
          area <<- AREA - overlap/2
          }
  
  ##### Calculate total crime densities ----
  ## query all the crimes for the school inside the circle 
  t0 <- Sys.time()
  print( paste("school:", schools[[index]]["School"]))
  createMongo()
  query <- sprintf('{ "School": "%s", "SchoolDistance": { "$lte": %f }}', school[["School"]], MAX_DIST)
  crimes <- mongo.find.all(mongo, "DSproject.londonCrime6", query)
  t1 <- Sys.time()
  print( "time to query crimes within distance:" )
  print( t1 - t0 )
  
  
  totals <-  c(crimeType = "Totals", crimeDensities(crimes,school))
  
  crimeTypes <- mongo.distinct(mongo, CRIME, "Crimetype")
  
  densities <- sapply(crimeTypes, function(crimetype) {
    print( crimetype )
    query <- sprintf('{ "School": "%s", "SchoolDistance": { "$lte": %f }, "Crimetype": "%s"}',
                     school[["School"]], MAX_DIST, crimetype)
    crimes <- mongo.find.all(mongo, "DSproject.londonCrime6", query)
    row <- c(crimetype, crimeDensities(crimes, school, crimetype))
  })
  densities <- t(cbind(totals, densities))
  
  ###  update queries
  createMongo()
  query <- sprintf( '{ "School": "%s" }', school[["School"]] )
  update <- list( "$set" = list( "Count" = densities[,2], "Crime Density" = densities[,3], "Crime Density (Gaussian)" = densities[,4], "Crime Density Vs Borough" = densities[,5], "Crime Density Vs Borough (Gaussian)" = densities[,6]))
  mongo.update(mongo, "DSproject.secSchoolsLond", query, update)
  
  print(paste(school[["School"]], Sys.time()))
})