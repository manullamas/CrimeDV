
library(rmongodb)
library(dplyr)

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

CRIME <- paste(DB, "londonCrime6", sep=".")

files <- list.files(path = "processed", full.names = TRUE, recursive = TRUE)
fileNames <- list.files(path = "processed", full.names = FALSE, recursive = TRUE)
londonfiles <- grep( pattern = ("city-of-london-street|metropolitan-street|btp-street"), files, value = TRUE)
londonNames <- grep( pattern = ("city-of-london-street|metropolitan-street|btp-street"), fileNames, value = TRUE)
londonNames <- gsub("^.*?/", "", londonNames)


totalProcessed <- 0
filesProcessed <- 0

for (i in seq(1, 174, 1)) {
  
  table <- read.csv(londonfiles[i])

  dataframe <- table[,2:16]
  t4 <- Sys.time()
  names(dataframe) <- gsub("\\.", "", names(dataframe))
  dataframe$CrimeID <- as.character(dataframe$CrimeID)
  dataframe$Month <- as.character(dataframe$Month)
  dataframe$Reportedby <- as.character(dataframe$Reportedby)
  dataframe$Fallswithin <- as.character(dataframe$Reportedby)
  dataframe$Latitude <- as.numeric(dataframe$Latitude)
  dataframe$Longitude <- as.numeric(dataframe$Longitude)
  dataframe$Location <- as.character(dataframe$Location)
  dataframe$LSOAcode <- as.character(dataframe$LSOAcode)
  dataframe$LSOAname <- as.character(dataframe$LSOAname)
  dataframe$Crimetype <- as.character(dataframe$Crimetype)
  dataframe$Lastoutcomecategory <- as.character(dataframe$Lastoutcomecategory)
  dataframe$Context <- as.character(dataframe$Context)
  dataframe$School <- as.character(dataframe$School)
  dataframe$SchoolDistance <- as.numeric(dataframe$SchoolDistance)
  dataframe$LocalAuthority <- as.character(dataframe$LocalAuthority)
  
  entriesLondon <- nrow(dataframe)

  bson <- mongo.bson.from.df(dataframe)
  
  t5 <- Sys.time()
  print(paste("Time to process bson:", round(t5 - t4, 4), attr(t5 - t4, "units")))
  
  # Insert into mongodb (must be done in batches of ~40000 or fails)
  
  createMongo()
  batchSize <- 1000
  batches <- ceiling( entriesLondon / batchSize )
  remainder <- entriesLondon %% batchSize
  for (j in 1:(batches)) {
    if (batches != 1) {
      if ( j == batches) {
        min <- entriesLondon - remainder
        createMongo
        mongo.insert.batch(mongo, CRIME, bson[min:entriesLondon])
      } else {
        min <- ((j - 1)*batchSize + 1)
        max <- j*(batchSize)
        createMongo()
        mongo.insert.batch(mongo, CRIME, bson[ min:max ])
      }
      
    } else {
      createMongo()
      mongo.insert.batch(mongo, CRIME, bson)
    }
    print(paste("Batch", j, "of", batches, "inserted"))
  }
  t6 <- Sys.time()
  print(paste("Time to insert documents:", round(t6 - t5, 4), attr(t6 - t5, "units")))
  totalProcessed <- totalProcessed + entriesLondon
  print(paste("Total Entries Processed:", totalProcessed))
  print(paste("number of londonfile just processed:", i))

}
