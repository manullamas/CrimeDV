CREATE TABLE [dbo].[Stations]
(
    [Station] NVARCHAR(50) NULL, 
    [Latitude] REAL NULL, 
    [Longitude] REAL NULL, 
    [Zone] INT NULL, 
    [PostCode] NVARCHAR(10) NULL,
	[Borough] NVARCHAR(50) NULL,
	[Owner] NVARCHAR(50) NULL,
	[TicketUsage] INT NULL,
	[railComments] NVARCHAR(150) NULL,
	[EntryExitEst] INT NULL,
	[tubeComments] NVARCHAR(150) NULL,
	[usage] INT NULL,
	[Type] NVARCHAR(20) NULL
)

