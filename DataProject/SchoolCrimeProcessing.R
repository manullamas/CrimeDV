library(rmongodb)
library(dplyr)

#------ Defining gloabl variables ---------
DB <- "DSproject"
CRIME <- paste(DB, "londonCrime6", sep = ".")
SCHOOLS <- paste(DB, "schools", sep = ".")
startTime <- Sys.time()
mongo <- mongo.create(host = "mongodb-dse662l3.cloudapp.net:27017", db = DB)
#mongo <- NA

# creating schools dataset
schools <- data.frame(
  School = secSchoolsLondon$EstablishmentName,
  Latitude = secSchoolsLondon$Latitude,
  Longitude = secSchoolsLondon$Longitude,
  Borough = secSchoolsLondon$LA..name.,
  TypeOfSchool = secSchoolsLondon$TypeOfEstablishment..name.)
schools$Latitude <- as.numeric(schools$Latitude)
schools$Longitude <- as.numeric(schools$Longitude)
schools$School <- as.character(schools$School)
schools$Borough <- as.character(schools$Borough)
schools$TypeOfSchool <- as.character(schools$TypeOfSchool)

# Filter in case if its still schools outside London
schools <- filter(schools, grepl(c("^Barking and Dagenham$|^Barnet$|^Bexley$|^Brent$|^Bromley$|^Camden$|^City of London$|^Croydon$|^Ealing$|^Enfield$|^Greenwich$|^Hackney$|^Hammersmith and Fulham$|^Haringey$|^Harrow$|^Havering$|^Hillingdon$|^Hounslow$|^Islington$|^Kensington and Chelsea$|^Kingston upon Thames$|^Lambeth$|^Lewisham$|^Merton$|^Newham$|^Redbridge$|^Richmond upon Thames$|^Southwark$|^Sutton$|^Tower Hamlets$|^Waltham Forest$|^Wandsworth$|^Westminster$"),schools$Borough))

# Remove Bradstow school and Bowden House (not in London bur ruled by some boroughs of London)
schools <- filter(schools, !grepl(c("^Bowden House School$|^Bradstow School$"), schools$School))


# Insert dataset in mongodb
schoolsBson <- mongo.bson.from.df(schools)
mongo.insert.batch(mongo, SCHOOLS, schoolsBson)



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


# Creating mongo connection
createMongo <- function() {
    if (exists("mongo")) {
        try(mongo.destroy(mongo))
    }
    mongo <<- mongo.create(host = "mongodb-dse662l3.cloudapp.net:27017", db = DB)
    return(mongo.is.connected(mongo))
}

# Downloading Datasets
createMongo()
Schools <- mongo.find.all(mongo, SCHOOLS)

# invisible(lapply(Schools[[1]], function(x) {
#     # Find all crimes associated with that School
#     SchoolCrime <- mongo.find.all(mongo, CRIME, (paste0('{ "School":"', x[["School"]] ,'"}')))
#     # Calculate a weighted crime density
#     #lapply(SchoolCrime, )
# }))

############ CALCULATE MINIMUM DISTANCES BETWEEN SchoolS ##################
createMongo()
schoolDistances <- mongo.find.all(mongo, SCHOOLS, fields = '{ "_id":0, "School":1, "Latitude":1, "Longitude":1}')
schoolsDF <- data.frame(School = character(), Latitude = numeric(), Longitude = numeric(), stringsAsFactors = F)
schoolsDF <- rbind(schoolsDF, schoolDistances[[1]])
schoolsDF$School <- as.character(schoolsDF$School)
invisible(sapply(2:length(schoolDistances), function(x){
  schoolsDF <<- rbind(schoolsDF, schoolDistances[[x]])
}))

nearestSchool <- data.frame()
invisible(apply(schoolsDF, 1, function(fixed) {
  index <- schoolsDF$School == as.list(fixed["School"])
  filtered <- schoolsDF[!index,]
  distances <- apply( filtered, 1, function(y) {
    distance(as.numeric(fixed["Latitude"]), as.numeric(fixed["Longitude"]), 
             as.numeric(y["Latitude"]), as.numeric(y["Longitude"]))
  })
  x <- list()
  x["NearestSchool"]  <- filtered[which.min(distances), "School"]
  x["NearestSchoolDist"] <- min(distances)
  nearestSchool$NearestSchool <- as.character(nearestSchool$NearestSchool)
  nearestSchool <<- rbind(nearestSchool, x)
}))

###### I mportant, delete previous collection of MongoDb, we dont need it anymore as this is more complete
schoolsDF <- cbind(schoolsDF, nearestSchool)
schoolsDFbson <- mongo.bson.from.df(schoolsDF)
mongo.insert.batch(mongo, SCHOOLS, schoolsDFbson)

hist(nearestSchool$NearestSchoolDist[nearestSchool$NearestSchoolDist!=0],150, main = "Distance between Schools", xlab="Distances (km)", ylab= "Frequency", col = "lightblue")

#####################################################################################################
 # densities of crime (given an area surrounding the schools)


createMongo()
schools <- mongo.find.all(mongo, SCHOOLS, '{"Crimes": { "$exists":0 }}')

# Calculate area of circle (in m^2)
MAX_DIST <- 0.3*1000
AREA <- pi * (MAX_DIST/2)^2 

# loop through each station
sapply(1:length(schools), function(index){
  area <- AREA
  school <- schools[[index]]
  
  #     # Check if there is another station overlapping the cirlce
      if (school["NearestSchoolDist"]!=0) {
  #     if (school["NearestSchoolDist"] < MAX_DIST*2) {
  #         stations[index, "Overlapping"] <<- TRUE
  #         d <- school["NearestSchoolDist"]
  #         r <- MAX_DIST
  #         overlap <- 2 * r^2 * acos(d/(2*r)) - (d/2) * sqrt(4*r^2 - d^2)
  #         area <<- AREA - overlap/2
  #         }
      }
  #     
  #### FOR ALL CRIMETYPES -------
  ## query all the crimes for the station inside the circle 
  createMongo()
  query <- sprintf('{ "School": "%s", "SchoolDistance": { "$lte": %f }}', school[["School"]], MAX_DIST)
  crimes <- mongo.find.all(mongo, CRIME, query)
  
  # Number of crimes
  crimeCount <- length(crimes)
  # Calculate density
  crimeDensity <- length(crimes) / area
  # Calculate Gaussian weighted density
  # Calculate relative densities
  
  # Update
  createMongo()
  query <- sprintf( '{ "School": "%s" }', school[["School"]] ) 
  update <- sprintf('{"$set": { "CrimeDensity": %f, "Crimes": %d}}', crimeDensity, crimeCount)
  createMongo()
  mongo.update(mongo, SCHOOLS, query, update)
  
  
  ### REPEAT FOR DIFFERENT CRIME TYPES
  crimeTypes <- mongo.distinct(mongo, CRIMES, "Crimetype")
  apply(crimeTypes, )
    crimes["CrimeTypes"]
  
  print(school[["School"]])
  
  
  ## TODO: test this code
  ## TODO: update other crime summaries such as totoal crimes of different types.
  ## TODO: apply weighting functions such as gaussian
})


