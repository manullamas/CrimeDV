BULK INSERT Stations
	FROM 'C:\Users\miballe\Desktop\LONCrime\stations2.csv'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		ERRORFILE = 'C:\Users\miballe\Desktop\LONCrime\stations2err.csv',
		TABLOCK
	)