for (i in seq(1, 174, 1)) {
  
  table <- read.csv(londonfiles[i])
  #delete id_ column (introduced by mongodb)
  dataframe <- table[,2:16]
  
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
  
  write.csv(dataframe, paste0("processed2/", londonNames[i]))
    
  print(paste("number of londonfile just processed:", i))
}

# load files using mongoimport ->much faster