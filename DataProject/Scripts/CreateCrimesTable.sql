CREATE TABLE [dbo].[Crimes]
(
	[CrimeID] NVARCHAR(100) NULL,
	[Month] NVARCHAR(10) NULL,
	[ReportedBy] NVARCHAR(50) NULL,
	[FallsWithin] NVARCHAR(30) NULL,
	[Longitude] REAL NULL,
	[Latitude] REAL NULL,
	[Location] NVARCHAR(100) NULL,
	[LSOACode] NVARCHAR(20) NULL,
	[LSOAName] NVARCHAR(50) NULL,
	[CrimeType] NVARCHAR(35) NULL,
	[LastOutcomeCategory] NVARCHAR(50) NULL,
	[Context] NVARCHAR(50) NULL,
)