SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Event](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[TargetUserID] [int] NULL,
	[EventTypeID] [int] NOT NULL,
	[Date] [datetime] NULL,
	[Text] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventType]    Script Date: 5/28/2020 12:07:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
 CONSTRAINT [PK_EventType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 5/28/2020 12:07:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Event]  WITH CHECK ADD  CONSTRAINT [FK_Event_EventType] FOREIGN KEY([EventTypeID])
REFERENCES [dbo].[EventType] ([ID])
GO
ALTER TABLE [dbo].[Event] CHECK CONSTRAINT [FK_Event_EventType]
GO
ALTER TABLE [dbo].[Event]  WITH CHECK ADD  CONSTRAINT [FK_Event_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Event] CHECK CONSTRAINT [FK_Event_User]
GO
ALTER TABLE [dbo].[Event]  WITH CHECK ADD  CONSTRAINT [FK_Event_User1] FOREIGN KEY([TargetUserID])
REFERENCES [dbo].[User] ([ID])
GO
ALTER TABLE [dbo].[Event] CHECK CONSTRAINT [FK_Event_User1]
GO
/****** Object:  StoredProcedure [dbo].[spAggregateSelect]    Script Date: 5/28/2020 12:07:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAggregateSelect] @Minutes INT AS

DECLARE @SQLString varchar(255)

SET @SQLString = 'SELECT * FROM Event_Agg_'+CONVERT(varchar(10),@Minutes)
EXEC (@SQLString)
GO
/****** Object:  StoredProcedure [dbo].[spETLProcessRun]    Script Date: 5/28/2020 12:07:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spETLProcessRun] @Minutes INT, @initDate DATETIME, @finalDate DATETIME AS 

DECLARE @startDate DATETIME = @initDate
DECLARE @endDate DATETIME = DATEADD(minute, @Minutes, @startDate)

DECLARE @EnterCount INT
DECLARE @LeaveCount INT
DECLARE @CommentCount INT
DECLARE @HiFiveCount INT

DECLARE @SQLString varchar(1024)

SET @SQLString = 'CREATE TABLE Event_Agg_'+CONVERT(varchar(10),@Minutes) + '( StartDate Datetime, EndDate Datetime, Enter INT, Leave INT, Comment INT, HiFive INT ); '
EXEC (@SQLString)

WHILE @endDate < @finalDate
BEGIN
	SET @endDate = DATEADD(minute, @Minutes, @startDate)

	SELECT @EnterCount = COUNT(ID) FROM [Event]
	WHERE [EventTypeID] = ( SELECT ID FROM EventType 
								WHERE Name = 'enter-the-room'
								AND [Date] >= @startDate
								AND [Date] <  @endDate
						)


	SELECT @LeaveCount = COUNT(ID) FROM [Event]
	WHERE [EventTypeID] = ( SELECT ID FROM EventType 
						WHERE Name = 'leave-the-room'
						AND [Date] >= @startDate
						AND [Date] <  @endDate
						)

	SELECT @CommentCount = COUNT(ID) FROM [Event]
	WHERE [EventTypeID] = ( SELECT ID FROM EventType 
						WHERE Name = 'comment'
						AND [Date] >= @startDate
						AND [Date] <  @endDate
						)

	SELECT @HiFiveCount = COUNT(ID) FROM [Event]
	WHERE [EventTypeID] = ( SELECT ID FROM EventType 
						WHERE Name = 'high-five-another-user'
						AND [Date] >= @startDate
						AND [Date] <  @endDate
						)

	SET @SQLString = 'INSERT INTO Event_Agg_'+CONVERT(varchar(10),@Minutes)+' (StartDate, EndDate, Enter, Leave, Comment, HiFive) VALUES ('''+CONVERT(varchar(30),@startDate)+''','''+CONVERT(varchar(30),@endDate)+''','+CONVERT(varchar(10),@EnterCount)+','+CONVERT(varchar(10),@LeaveCount)+','+CONVERT(varchar(10),@CommentCount)+','+CONVERT(varchar(10),@HiFiveCount)+')'
	EXEC (@SQLString)

	SET @startDate = @endDate

END
GO
/****** Object:  StoredProcedure [dbo].[spPopulateEventsTable]    Script Date: 5/28/2020 12:07:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spPopulateEventsTable] AS

DECLARE @cnt INT = 0;
DECLARE @rnd INT = 0;
DECLARE @eventType INT = 0;
DECLARE @user INT = 0;
DECLARE @targetUser INT = NULL ;
DECLARE @eventDate DATETIME = '2020-05-01 00:00:00'
DECLARE @Text nvarchar(255) = NULL

WHILE @cnt < 5000
BEGIN
   SET @Text = NULL
   SET @user = CAST(RAND()*((SELECT MAX(ID) FROM [User]))+1 as int)
   SET @eventType = CAST(RAND()*((SELECT MAX(ID) FROM [EventType]))+1 as int)

   IF ( @eventType = ( SELECT ID FROM [EventType] WHERE Name = 'high-five-another-user') )
	   SET @targetUser = CAST(RAND()*( ( SELECT MAX(ID) FROM [User] HAVING MAX(ID) <> 1 ))+1 as int) --different from previous user
	   
    IF ( @eventType = ( SELECT ID FROM [EventType] WHERE Name = 'comment') )
		SET @Text = 'This is a random comment'

   INSERT INTO [Event] (UserID, TargetUserID, EventTypeID, Date, Text) VALUES (@user, @targetUser, @eventType, @eventDate, @Text)

   SET @cnt = @cnt + 1;
   SET @targetUser = NULL
   SET @eventDate = DATEADD(minute, (RAND()*(10-5)+5), @eventDate) -- one event every random 1 to 5 minutes
END;
GO
/****** Object:  StoredProcedure [dbo].[spTransactionSelect]    Script Date: 5/28/2020 12:07:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spTransactionSelect] @startDate DATETIME, @endDate DATETIME
AS
SELECT [ID]
     , [Text]
     , ( SELECT [Name] FROM [User] Where [User].[ID] = [Event].[UserID] ) as UserName
	 , ( SELECT [Name] FROM [User] Where [User].[ID] = [Event].[TargetUserID] ) as TargetUserName
	 , ( SELECT [Name] FROM [EventType] Where [EventType].[ID] = [Event].[EventTypeID] ) as EventType
	 , [Date] FROM [Event]
	 WHERE [Event].Date > @startDate AND [Event].Date < @endDate
GO
