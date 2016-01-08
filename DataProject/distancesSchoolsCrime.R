library(rmongodb)

#------ Defining gloabl variables ---------
DB <- "DSproject"
mongo<-mongo.create(host = "mongodb-dse662l3.cloudapp.net:27017", db = DB)
CRIME <- paste(DB, "londonCrime6", sep=".")

#crime <- mongo.find.all(mongo, CRIME)
#This takes long time, but will be faster making queries!


#Using stations and schools dataset: find the nearest 5 schools to a given station, so to find the 
#corresponding crime will be much faster (nearest station included in crime dataset)


#--------------------Loading schools dataset---------------------#

#Loading xlsx library to read datasets and dplyer to apply filters
library(xlsx)
library(dplyr)

#Load dataset
schoolsLondon <- read.xlsx("2_LondonSchools.xlsx", "Sheet1")
#Cleaning Schols dataset not to take into account Nursery and Primary ones: If we are relating crimes with schools, makes sense to study secondary ones (more likely to commit/suffer a crime)
clean1 <- filter(schoolsLondon, PhaseOfEducation..name. != "Primary")
secSchoolsLondon <- filter(clean1, PhaseOfEducation..name. != "Nursery")


#-------------------Downloading stations dataset--------------------#

STATIONS <- paste(DB, "stations", sep=".")

#download stations in a list from mongodb
if (mongo.is.connected(mongo) == TRUE) {
  lstations <- mongo.find.all(mongo, STATIONS)
} else {(mongo<-mongo.create(host = "mongodb-dse662l3.cloudapp.net:27017", db = DB))
  lstations <- mongo.find.all(mongo, STATIONS)
  }

#convert that list in a dataframe with name and coordinates
stations <- data.frame(
  Station = sapply(lstations, function(x) x$Station),
  Latitude = sapply(lstations, function(x) x$Latitude),
  Longitude = sapply(lstations, function(x) x$Longitude))


#stations$Latitude <- as.numeric(stations$Latitude)
#stations$Longitude <- as.numeric(stations$Longitude)


#Create a dataframe with distances from schools to stations
m <- matrix(ncol=nrow(secSchoolsLondon), nrow=nrow(stations))
DistStationsSchools <- data.frame(m)
rownames(DistStationsSchools) <- stations$Station
colnames(DistStationsSchools) <- secSchoolsLondon$EstablishmentName 
counter=0
for (i in 1:nrow(stations)) {
  counter=counter+1
  print(counter)
  for (j in 1:nrow(secSchoolsLondon)) {
    DistStationsSchools[i,j] <- (stations$Latitude[i] - secSchoolsLondon$Latitude[j]) ^ 2 + (stations$Longitude[i] - secSchoolsLondon$Longitude[j]) ^ 2
    }
}

#

############## Check the 10 nearest stations to given schools 

nearStat <- matrix(nrow=nrow(secSchoolsLondon), ncol=10)
nearStat <- data.frame(nearStat)
#rownames(nearStat) <- secSchoolsLondon$EstablishmentName
#cannot name the rows as the schools' names as there are 2 repeated(same name BUT DIFFERENT SCHOOL: not neglictible)
#So to introduce the nearest stations to schools dataset I will work with indexes (it is in the same order)
colnames(nearStat) <- c("stat1", "stat2", "stat3", "stat4", "stat5")

counter=0
for (n in 1:ncol(DistStationsSchools)) {
  counter=counter+1
  print(counter)
  minDist <- head(sort(DistStationsSchools[,n]),5)
  for (l in 1:length(minDist)) {
    #which(DistStationsSchools[,n]==minDist[l])
    nearStat[n,l] <- paste(rownames(DistStationsSchools[which(DistStationsSchools[,n]==minDist[l]),]),collapse=" , ")
  }
}

## Convert stations vector in characters
nearStatTraspose <- data.frame(t(nearStat))
nearstatCharacter <- vector(mode="character", length=ncol(prueba))
for (o in 1:ncol(nearStatTraspose)) {
  nearStatCharacter[o] <- paste(unique(nearStatTraspose[,o]),collapse=" , ")
}

# Join the two dataframes so we have nearest stations in schools' dataset
#secSchoolsLondon <- cbind(secSchoolsLondon,nearStat)
secSchoolsLondon<-cbind(secSchoolsLondon,nearStatCharacter)


mongo.findOne(mongo,CRIME)
class(mongo.findOne(mongo, CRIME))

mongo.bson.find(CRIME, "$station")
que <- list(Station="Chancery Lane", LocalAuthority="Camden")
mongo.bson.from.list(que)
prueba<- mongo.find(mongo,CRIME,que)
## mongo.cursor















# creatind schools dataset

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







files <- list.files(path = "Datasets/NationalData", full.names = TRUE, recursive = TRUE)
fileNames <- list.files(path = "Datasets/NationalData", full.names = FALSE, recursive = TRUE)
londonfiles <- grep( pattern = ("city-of-london-street|metropolitan-street|btp-street"), files, value = TRUE)
londonNames <- grep( pattern = ("city-of-london-street|metropolitan-street|btp-street"), fileNames, value = TRUE)
londonNames <- gsub("^.*?/", "", londonNames)

LSOA <- read.csv("Datasets/LSOAlookup/OA11_LSOA11_MSOA11_LAD11_EW_LUv2.csv", stringsAsFactors = F)
names(LSOA) <- c("OutputAreaCode", "LSOAcode", "LSOAname", "MSOAcode", "MSOAname", "LAcode", "LAname", "LAWelshName")




########## Reading Borough collection ##############

if (mongo.is.connected(mongo)==T) {
   #boroughCursor <- mongo.find(mongo, "DSproject.boroughs")
  boroughs<-mongo.find.all(mongo,"DSproject.boroughs")
} else {
  createMongo()
  #boroughCursor <- mongo.find(mongo, "DSproject.boroughs")
  boroughs<-mongo.find.all(mongo,"DSproject.boroughs")
}
## Converting to dataframe
boroughs <- data.frame(
  Borough = sapply(boroughs, function(x) x$boroughs),
  AreaKm = sapply(boroughs, function(x) x$AreaKm))

#############################################################

totalProcessed <- 0
filesProcessed <- 0
#################

startTime <- Sys.time()
for (i in seq(1, 174, 3)) {
  
  
  t2a <- Sys.time()
  table <- read.csv(londonfiles[i])
  entries <- nrow(table)

  t3 <- Sys.time()
  print(paste("Processing:", londonfiles[i]))
  print(paste("Time to read csv:", round(t3 - t2a, 4), attr(t3 - t2a, "units"), 
              "(", entries, " Entries )"))
  
  # Loop over every school for every crime in file
  processed <- apply(table, 1, function(x){
    # Calculate distance to school
    distances <- apply(schools, 1, function(y) {
      distRad(as.numeric(x["Latitude"]), as.numeric(x["Longitude"]),
              as.numeric(y["Latitude"]), as.numeric(y["Longitude"]))    
    })
    
    # Adding station distance and name dimensions to crime vector
    # Check to ensure data is fit to be inserted into mongodb
    if (all(is.na(distances))) {
      x["School"] <- NA
      x["SchoolDistance"] <- NA
    }
    else {
      index <- which.min(distances)
      x["School"] <- schools$School[index]
      kilometers <- distance(as.numeric(x["Latitude"]), as.numeric(x["Longitude"]),
                             as.numeric(schools$Latitude[index]),
                             as.numeric(schools$Longitude[index]))
      x["SchoolDistance"] <- kilometers
    }
    
    # Calculate LSOA name and LA name
    x["LocalAuthority"] <- filter(LSOA, LSOAcode == x["LSOA.code"])[1,"LAname"]
    return(x)
  })

  
  # Filter the crimes only in London (by boroughs)
 #####################################
  processedTras <- as.data.frame(t(processed),stringsAsFactors = F)
  dataframe <- filter(processedTras, grepl(c("^Barking and Dagenham$|^Barnet$|^Bexley$|^Brent$|^Bromley$|^Camden$|^City of London$|^Croydon$|^Ealing$|^Enfield$|^Greenwich$|^Hackney$|^Hammersmith and Fulham$|^Haringey$|^Harrow$|^Havering$|^Hillingdon$|^Hounslow$|^Islington$|^Kensington and Chelsea$|^Kingston upon Thames$|^Lambeth$|^Lewisham$|^Merton$|^Newham$|^Redbridge$|^Richmond upon Thames$|^Southwark$|^Sutton$|^Tower Hamlets$|^Waltham Forest$|^Wandsworth$|^Westminster$"),processedTras$LocalAuthority))
 ################################### 
  
  t4 <- Sys.time()
  print(paste("Time to make calculations:", round(t4 - t3, 4), attr(t4 - t3, "units")))
  
  # Remember next time to clean the names by removing the '.', not working in mongo!
  # names(dataframe) <- gsub("\\.", "", names(dataframe))
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
  
  write.csv(dataframe, paste0("processed/", londonNames[i]))
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
print(paste("time to compute schools:", Sys.time() - startTime))


############### CHECKING DISTANCES #################
#  distGeo(c(-3.55944,54.6445), c(schools$Longitude[schools$School=="The Harefield Academy"], schools$Latitude[schools$School=="The Harefield Academy"]))

