
####

library(rworldmap)
library(rworldxtra)
library(rmongodb)


# Load Schools dataframe
DB <- "DSproject"
CRIME <- paste(DB, "londonCrime6", sep = ".")
SCHOOLS <- paste(DB, "secSchoolsLond", sep = ".")
mongo <- mongo.create(host = "mongodb-dse662l3.cloudapp.net:27017", db = DB)
createMongo <- function() {
  if (exists("mongo")) {
    try(mongo.destroy(mongo))
  }
  mongo <<- mongo.create(host = "mongodb-dse662l3.cloudapp.net:27017", db = DB)
  return(mongo.is.connected(mongo))
}



# ##################################### uploading new school mongodb dataset (dont need this for stations)
# 
# secSchoolsLond <- data.frame(
#   School = secSchoolsLondon$EstablishmentName,
#   Latitude = secSchoolsLondon$Latitude,
#   Longitude = secSchoolsLondon$Longitude,
#   Borough = secSchoolsLondon$LA..name.,
#   TypeOfSchool = secSchoolsLondon$TypeOfEstablishment..name.,
#   PhaseOfEducation = secSchoolsLondon$PhaseOfEducation..name.,
#   Gender = secSchoolsLondon$Gender..name.,
#   ReligiousCharacter = secSchoolsLondon$ReligiousCharacter..name.,
#   Postcode = secSchoolsLondon$Postcode, stringsAsFactors = FALSE)
# 
# secSchoolsLond$Latitude <- as.numeric(secSchoolsLond$Latitude)
# secSchoolsLond$Longitude <- as.numeric(secSchoolsLond$Longitude)
# secSchoolsLond$School <- as.character(secSchoolsLond$School)
# secSchoolsLond$Borough <- as.character(secSchoolsLond$Borough)
# secSchoolsLond$TypeOfSchool <- as.character(secSchoolsLond$TypeOfSchool)
# secSchoolsLond$PhaseOfEducation <- as.character(secSchoolsLond$PhaseOfEducation)
# secSchoolsLond$Gender <- as.character(secSchoolsLond$Gender)
# secSchoolsLond$ReligiousCharacter <- as.character(secSchoolsLond$ReligiousCharacter)
# secSchoolsLond$Postcode <- as.character(secSchoolsLond$Postcode)
# 
# secSchoolsLond <- filter(secSchoolsLond, !grepl(c("^Bowden House School$|^Bradstow School$"), secSchoolsLond$School))
# 
# secSchoolsLondonUpdate <- cbind(secSchoolsLond, schoolsLocations[,4:5])
# secSchoolsLondonUpdate$NearestSchool <- as.character(secSchoolsLondonUpdate$NearestSchool)
# secSchoolsLondonUpdate$NearestSchoolDist <- as.numeric(secSchoolsLondonUpdate$NearestSchoolDist)
# 
# createMongo()
# secSchoolsBson <-  mongo.bson.from.df(secSchoolsLondonUpdate)
# mongo.insert.batch(mongo, SCHOOLS, secSchoolsBson)
# 

####################################################################################################################################
############################################  MAPS WITH SCHOOLS ####################################################################
####################################################################################################################################

# download secSchoolsLond dataset and turn it into dataframe
SchoolsLoc <- mongo.find.all(mongo, SCHOOLS)

#schoolsLocations <- do.call(rbind.data.frame, SchoolsLoc)

# delete first column (_id)
School <- vector()
Latitude <- vector()
Longitude <- vector()
Gender <- vector()
TypeOfSchool <- vector()
CountRobbery <- vector()
DensityRobbery <- vector()
CountTotals <- vector()
DensityTotals <- vector()
CountWeapons <- vector()
DensityWeapons <- vector()

invisible(sapply(SchoolsLoc, function(x) {
  School <<- c(School, x[["School"]])
  Latitude <<- c(Latitude, x[["Latitude"]])
  Longitude <<- c(Longitude, x[["Longitude"]])
  Gender <<- c(Gender, x[["Gender"]])
  TypeOfSchool <<- c(TypeOfSchool, x[["TypeOfSchool"]])
  CountRobbery <<- c(CountRobbery, x$Count$Robbery)
  DensityRobbery <<- c(DensityRobbery, x$`Crime Density`$Robbery)
  CountTotals <<- c(CountTotals, x$Count$totals)
  DensityTotals <<- c(DensityTotals, x$`Crime Density`$totals)
  CountWeapons <<- c(CountWeapons, x$Count$`Possession of weapons`)
  DensityWeapons <<- c(DensityWeapons, x$`Crime Density`$`Possession of weapons`)
}))

schoolsLocations <- as.data.frame(data.frame(School=School, Latitude=Latitude, Longitude=Longitude, Gender=Gender, TypeOfSchool=TypeOfSchool, CountTotals=CountTotals, DensityTotals=DensityTotals,CountRobbery=CountRobbery, DensityRobbery=DensityRobbery, CountWeapons=CountWeapons, DensityWeapons=DensityWeapons))


#schoolsLocations <- schoolsLocations[,2:12]

####################################################################################################################################
################################################### All Schools Map ################################################################
####################################################################################################################################

library(ggmap)
library(mapproj)

######### Create London map

map <- get_map(location = 'London', zoom = 10)
ggmap(map)
#newmap <- getMap(resolution = "high")
#plot(newmap, xlim = c(-3, 3), ylim = c(47, 53), asp = 2)



mapPoints <- ggmap(map) + 
  geom_point(aes(x = Longitude, y = Latitude, size =CountTotals, color = CountTotals), data = schoolsLocations , alpha = .5) + 
                            scale_color_continuous(low ="blue", high ="red") +
                            scale_size_continuous(range=c(2, 5)) +
                            ggtitle("CountTotals")
plot(mapPoints)
title(main="Density Totals",cex.main=3)


###                                  %%%%%%%% Should I add road M25 boundary??

####################################################################################################################################
################################################### FILTERED SCHOOLS MAPS:  GENDER #################################################
####################################################################################################################################

library(ggmap)
library(mapproj)

######### Create London map

mapGender <- get_map(location = 'London', zoom = 10)
ggmap(mapGender)
#newmap <- getMap(resolution = "high")
#plot(newmap, xlim = c(-3, 3), ylim = c(47, 53), asp = 2)

schoolsLocationsGirls <- schoolsLocations[schoolsLocations$Gender=="Girls",]
schoolsLocationsBoys <- schoolsLocations[schoolsLocations$Gender=="Boys",]
schoolsLocationsMixed <- schoolsLocations[schoolsLocations$Gender=="Mixed",]


mapPointsGender <- ggmap(mapGender) + geom_point(aes(x = Longitude, y = Latitude, size = 3, color = "red"), data = schoolsLocationsGirls , alpha = .5) + 
  geom_point(aes(x = Longitude, y = Latitude, size = 3), data = schoolsLocationsBoys, color = "cadetblue4" , alpha = .5) +
  geom_point(aes(x = Longitude, y = Latitude, size = 3), data = schoolsLocationsMixed ,color = "black", alpha = .5)

##    %%%%%%%%%     scale_color/size...( ) to scale colors/size  --> put the related field to color inside aes() function in this case

### maybe if I set color = (crimeCount) is going to set the color in function of it, already scaled
             
plot(mapPointsGender)

## study further plots with densities





