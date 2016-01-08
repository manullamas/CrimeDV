SET NOCOUNT ON;

-- Original fields from a crime entry to fetch a record values into them.
-- This is for later insert a new record in a separate table with the values
-- of closest station and distance.
DECLARE @CrimeID NVARCHAR(100),
		@Month NVARCHAR(10),
		@ReportedBy NVARCHAR(50),
		@FallsWithin NVARCHAR(30),
		@CLongitude REAL,
		@CLatitude REAL,
		@Location NVARCHAR(100),
		@LSOACode NVARCHAR(20),
		@LSOAName NVARCHAR(50),
		@CrimeType NVARCHAR(35),
		@LastOutcomeCategory NVARCHAR(50),
		@Context NVARCHAR(50)

-- These are the values that will be calculated for the closest station and then used for the
-- record insert.
DECLARE @MStation NVARCHAR(50) = '',
		@MStDistance REAL = 1000

-- Variables to fetch the records form the stations table and being used within the stations loop
DECLARE @Station NVARCHAR(50),
		@SLongitude REAL,
		@SLatitude REAL

-- Values to add to the crime lat/lon to define a square around it and therefore get a reduced 
-- list of candidate stations 
DECLARE @LatOffset REAL = 0.02,
		@LonOffset REAL = 0.03

DECLARE @CalcDistance REAL

PRINT 'Declare crime cursor ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
-- Cursor for the iteration through all Crime records
DECLARE crimes_cursor CURSOR FOR 
	SELECT C.CrimeID, C.Month, C.ReportedBy, C.FallsWithin, C.Longitude, C.Latitude, C.Location, C.LSOACode, C.LSOAName, C.CrimeType, C.LastOutcomeCategory, C.Context
	FROM Crimes as C
	-- WHERE C.ClosestStation is null or C.DistClosestStation is null
	-- WHERE crimeid in ('991b20bc913d950fb0ddb49ca7cdfc6ce6528f8938e985c37819d847931b77a6', '1b530f32f98f0cb4a5721974ad6562312f7dbc685aa7e29a36825aae87fd81a1', 'b1a33193a9aec4891a53eb13d495ef405e8db0825b7ebfb6fdeba21effeea38e')

PRINT 'Open crime cursor ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
OPEN crimes_cursor

-- Initial fetch of the Crimes cursor. This operation is executed again at the end of each loop
FETCH NEXT FROM crimes_cursor 
	INTO @CrimeID, @Month, @ReportedBy, @FallsWithin, @CLongitude, @CLatitude, @Location, @LSOACode, @LSOAName, @CrimeType, @LastOutcomeCategory, @Context

PRINT 'Start crimes loop ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Cursor for the iteration through the Station records
	-- PRINT 'Declare stations cursor ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
    DECLARE stations_cursor CURSOR FOR 
		SELECT S.Station, S.Latitude, S.Longitude
		FROM Stations as S
		WHERE S.Latitude > @CLatitude - @LatOffset
			and S.Latitude < @CLatitude + @LatOffset
			and S.Longitude > @CLongitude - @LonOffset
			and S.Longitude < @CLongitude + @LonOffset

	-- PRINT 'Open stations cursor ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
    OPEN stations_cursor

	-- Initial fetch of the station records. This operation is executed again at the end of each loop.
    FETCH NEXT FROM stations_cursor
		INTO @Station, @SLatitude, @SLongitude

	SET @MStDistance = 1000

	-- PRINT 'Start stations loop ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
    WHILE @@FETCH_STATUS = 0
    BEGIN
		-- For each record the distance is measured to the current crime entry. If the value is lower than
		-- all previous records, the station and distance variables are reassigned. For the first iteration
		-- the initial value of distance is very high.
		SET @CalcDistance = [dbo].[fn_calcDistanceKm](@CLatitude, @CLongitude, @SLatitude, @SLongitude)
		-- SET @CalcDistance = 0.7
		IF @CalcDistance < @MStDistance BEGIN
			SET @MStDistance = @CalcDistance
			SET @MStation = @Station
		END

		FETCH NEXT FROM stations_cursor
			INTO @Station, @SLatitude, @SLongitude
    END
	-- PRINT 'End stations loop ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
	-- After iterating through all candidate stations, a new record is inserted in the destination table with the same
	-- Crime records and the two calculated additional ones (station and distance to the station)
	-- PRINT 'Insert NCrimes record ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
	INSERT INTO NCrimes
	VALUES (@CrimeID, @Month, @ReportedBy, @FallsWithin, @CLongitude, @CLatitude, @Location, @LSOACode, @LSOAName, @CrimeType, @LastOutcomeCategory, @Context, @MStation, @MStDistance); 

    CLOSE stations_cursor
    DEALLOCATE stations_cursor

    FETCH NEXT FROM crimes_cursor 
    INTO @CrimeID, @Month, @ReportedBy, @FallsWithin, @CLongitude, @CLatitude, @Location, @LSOACode, @LSOAName, @CrimeType, @LastOutcomeCategory, @Context
END 
PRINT 'End crimes loop ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
CLOSE crimes_cursor;
DEALLOCATE crimes_cursor;
PRINT 'End procedure ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
