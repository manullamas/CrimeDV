DECLARE @i int = 2010
DECLARE @j int = 12
DECLARE @File_Exists int 
DECLARE @MONTHSTR varchar(7)
DECLARE @LCSVFPATH nvarchar(150)
DECLARE @MCSVFPATH nvarchar(150)
DECLARE @LERRFPATH nvarchar(150)
DECLARE @MERRFPATH nvarchar(150)
DECLARE @BIMPORTL nvarchar(1500)
DECLARE @BIMPORTM nvarchar(1500)

WHILE @i <= 2015 BEGIN
	SET @j = 1
	WHILE @j <= 12 BEGIN
		IF @j < 10
			SET @MONTHSTR = CAST(@i AS varchar(5)) + '-0' + CAST(@j AS varchar(5))
		ELSE
			SET @MONTHSTR = CAST(@i AS varchar(5)) + '-' + CAST(@j AS varchar(5))
		
		SET @LCSVFPATH = N'C:\Users\miballe\Documents\GitHub\CrimeDV\DataProject\Datasets\NationalData\' + @MONTHSTR + '\' + @MONTHSTR + '-city-of-london-street.csv'
		SET @MCSVFPATH = N'C:\Users\miballe\Documents\GitHub\CrimeDV\DataProject\Datasets\NationalData\' + @MONTHSTR + '\' + @MONTHSTR + '-metropolitan-street.csv'
		SET @LERRFPATH = N'C:\Users\miballe\Documents\GitHub\CrimeDV\DataProject\Datasets\NationalData\' + @MONTHSTR + '\' + @MONTHSTR + '-city-of-london-street-err.csv'
		SET @MERRFPATH = N'C:\Users\miballe\Documents\GitHub\CrimeDV\DataProject\Datasets\NationalData\' + @MONTHSTR + '\' + @MONTHSTR + '-metropolitan-street-err.csv'

		EXEC Master.dbo.xp_fileexist @LCSVFPATH, @File_Exists OUT 

		PRINT 'File exist? ' + CAST(@File_Exists AS varchar(5))

		IF @File_Exists = 1 BEGIN
			PRINT 'Importing London...'
			SET @BIMPORTL = '
			BULK INSERT Crimes
				FROM ''' + @LCSVFPATH + '''
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = '','',
					ROWTERMINATOR = ''\n'',
					ERRORFILE = ''' + @LERRFPATH + ''',
					TABLOCK
				)'

			EXEC(@BIMPORTL)

			PRINT 'Importing Metropolitan...'
			SET @BIMPORTM = '
			BULK INSERT Crimes
				FROM ''' + @MCSVFPATH + '''
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = '','',
					ROWTERMINATOR = ''\n'',
					ERRORFILE = ''' + @MERRFPATH + ''',
					TABLOCK
				)'

			EXEC(@BIMPORTM)
		END
		SET @j = @j + 1
	END
    SET @i = @i + 1
END