# loading lybraries
library(dplyr)

# Load both datasets: %Schools% and %Postcodes%
secondarySchools <- read.csv("./Datasets/edubaseallstatefunded20151221.csv")
postcodes <- read.csv("./Datasets/ukpostcodes.csv")

# Filter schools: create a list only for London
summary(secondarySchools)
secSchoolsLondon <- filter(secondarySchools, Town == "London")
##prueba <- secondarySchools[secondarySchools$Town=="London",]
secSchoolsLondon <- filter(secSchoolsLondon, grepl(c("^Barking and Dagenham$|^Barnet$|^Bexley$|^Brent$|^Bromley$|^Camden$|^City of London$|^Croydon$|^Ealing$|^Enfield$|^Greenwich$|^Hackney$|^Hammersmith and Fulham$|^Haringey$|^Harrow$|^Havering$|^Hillingdon$|^Hounslow$|^Islington$|^Kensington and Chelsea$|^Kingston upon Thames$|^Lambeth$|^Lewisham$|^Merton$|^Newham$|^Redbridge$|^Richmond upon Thames$|^Southwark$|^Sutton$|^Tower Hamlets$|^Waltham Forest$|^Wandsworth$|^Westminster$"),secSchoolsLondon$LA..name.))
#Additional filter (just in case)

# Drop all levels of previous dataframe, so only working with current ones (necessary to loop??)
#secSchoolsLondon$Postcode <- factor(secSchoolsLondon$Postcode)
#typeof(secSchoolsLondon$Postcode)
# integer 


# Filter postcodes of London: clean1 select postcodes begining like London ones. Clean2 eliminates codes remaining not belonging to London area.
postcodes_clean1 <- filter(postcodes, grepl("^N|^E|^SE|^SW|^W|^NW|^EC|^WC", postcode))
postcodes_clean2 <- filter(postcodes_clean1, !grepl("^WV|^WS|^WR|^WN|^WF|^WD|^WA|^NR|^NP|^NN|^EX|^EN|^EH|^NE", postcode))
postcodesLondon <- postcodes_clean2


#Search the postcodes of the schools in the %Postcode Dataset%. It is very inneficient, but its no big problem as there is no need to update this really often (schools may close or open each year or each 2 years)
# first test with a subset --> it returns latitude perfectly

# First of all we need to have same levels in both datasets, if not it doesnt iterate through
secSchoolsLondon$Postcode <- factor(secSchoolsLondon$Postcode, levels=levels(postcodes$postcode))
#create latitude/longitude vector (later it will be added to %Schools Dataset%)
latitude <- c(1:nrow(subset))
longitude <- c(1:nrow(subset))
# Adding a counter to check how it is going
counter = 0
for (i in 1:nrow(secSchoolsLondon)){
  counter = counter + 1
  print(counter)
  latitude[i] <- postcodes$latitude[postcodes$postcode==secSchoolsLondon$Postcode[i]]
  longitude[i] <- postcodes$longitude[postcodes$postcode==secSchoolsLondon$Postcode[i]]
}

# Add new columns with coordinates in %Schools Dataset% (Long first, Lat after: better when using distGeo)
Schools <- data.frame(secSchoolsLondon, longitude,latitude)
#names(secSchoolsLondon_Lat)[34] <- "latitude"

#SchoolsWithCoordinates <- data.frame(secSchoolsLondon_Lat,vector(mode="numeric",length=nrow(secSchoolsLondon)))
#names(secSchoolsLondon_LatLong)[35] <- "longitude"

crime201012 <- read.csv("C:/Users/Manuel/Desktop/CrimeProject/CrimeDV/DataProject/Datasets/NationalData/2010-12/2010-12-city-of-london-street.csv")
library(geosphere)

#test distances

distGeo(secSchoolsLondon_LongLat[1,34:35],crime201012[1,5:6])
