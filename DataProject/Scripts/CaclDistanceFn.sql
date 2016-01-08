-- DROP FUNCTION fn_calcDistanceKm;
CREATE FUNCTION fn_calcDistanceKm (@Lat1 REAL, @Lon1 REAL, @Lat2 REAL, @Lon2 REAL) 
RETURNS REAL 
AS
BEGIN 
	DECLARE @Return REAL 
	DECLARE @a geography;
	DECLARE @b geography;
	SET @a = geography::STGeomFromText('POINT(' + CAST(@Lon1 AS varchar(15)) + ' ' + CAST(@Lat1 AS varchar(15)) + ')', 4326);
	SET @b = geography::STGeomFromText('POINT(' + CAST(@Lon2 AS varchar(15)) + ' ' + CAST(@Lat2 AS varchar(15)) + ')', 4326);
	SET @Return = @a.STDistance(@b) / 1000

RETURN @Return
END