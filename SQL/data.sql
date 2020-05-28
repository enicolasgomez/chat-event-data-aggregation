INSERT [dbo].[EventType] ([Name]) VALUES ('enter-the-room')
INSERT [dbo].[EventType] ([Name]) VALUES ('leave-the-room')
INSERT [dbo].[EventType] ([Name]) VALUES ('comment')
INSERT [dbo].[EventType] ([Name]) VALUES ('high-five-another-user')
INSERT [dbo].[User] ([Name]) VALUES ('test_user_1')
INSERT [dbo].[User] ([Name]) VALUES ('test_user_3')
INSERT [dbo].[User] ([Name]) VALUES ('test_user_4')
INSERT [dbo].[User] ([Name]) VALUES ('test_user_5')

Exec spPopulateEventsTable

Exec spETLProcessRun 30, '2020-05-01 00:00:00', '2020-05-31 00:00:00'
Exec spETLProcessRun 60, '2020-05-01 00:00:00', '2020-05-31 00:00:00'
Exec spETLProcessRun 240, '2020-05-01 00:00:00', '2020-05-31 00:00:00'
Exec spETLProcessRun 1440, '2020-05-01 00:00:00', '2020-05-31 00:00:00'

