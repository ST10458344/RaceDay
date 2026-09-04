```sql
USE master;

IF DB_ID(N'RaceDay') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDay SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDay;
END;

EXEC(N'CREATE DATABASE RaceDay');

USE RaceDay;

CREATE TABLE Roles (
    RoleId INT NOT NULL IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (RoleId),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName)
);

CREATE TABLE Users (
    UserId INT NOT NULL IDENTITY(1,1),
    Email NVARCHAR(256) NOT NULL,
    PasswordHash NVARCHAR(256) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Users PRIMARY KEY (UserId),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);

CREATE TABLE UserRoles (
    UserRoleId INT NOT NULL IDENTITY(1,1),
    UserId INT NOT NULL,
    RoleId INT NOT NULL,
    AssignedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UserRoles PRIMARY KEY (UserRoleId),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId),
    CONSTRAINT UQ_UserRoles_UserId_RoleId UNIQUE (UserId, RoleId)
);

CREATE TABLE Events (
    EventId INT NOT NULL IDENTITY(1,1),
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    EventDate DATE NOT NULL,
    StartTime TIME(0) NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    RouteDescription NVARCHAR(MAX) NULL,
    MaxParticipants INT NULL,
    CreatedByUserId INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsPublished BIT NOT NULL DEFAULT 0,
    CONSTRAINT PK_Events PRIMARY KEY (EventId),
    CONSTRAINT FK_Events_Users FOREIGN KEY (CreatedByUserId) REFERENCES Users(UserId),
    CONSTRAINT CK_Events_MaxParticipants CHECK (MaxParticipants IS NULL OR MaxParticipants > 0)
);

CREATE TABLE Categories (
    CategoryId INT NOT NULL IDENTITY(1,1),
    EventId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    DistanceKm DECIMAL(6,2) NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL DEFAULT 0,
    MinAge INT NULL,
    MaxAge INT NULL,
    MaxEntries INT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryId),
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) REFERENCES Events(EventId) ON DELETE CASCADE,
    CONSTRAINT UQ_Categories_EventId_Name UNIQUE (EventId, Name),
    CONSTRAINT CK_Categories_DistanceKm CHECK (DistanceKm > 0),
    CONSTRAINT CK_Categories_EntryFee CHECK (EntryFee >= 0),
    CONSTRAINT CK_Categories_AgeRange CHECK (
        (MinAge IS NULL AND MaxAge IS NULL) OR
        (MinAge IS NOT NULL AND MaxAge IS NOT NULL AND MinAge <= MaxAge)
    )
);

CREATE TABLE Enrolments (
    EnrolmentId INT NOT NULL IDENTITY(1,1),
    UserId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    BibNumber NVARCHAR(20) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT N'Confirmed',
    EmergencyContact NVARCHAR(100) NULL,
    CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentId),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT UQ_Enrolments_UserId_CategoryId UNIQUE (UserId, CategoryId),
    CONSTRAINT UQ_Enrolments_BibNumber UNIQUE (BibNumber),
    CONSTRAINT CK_Enrolments_Status CHECK (
        Status IN (N'Confirmed', N'Cancelled', N'Withdrawn')
    )
);

CREATE TABLE Results (
    ResultId INT NOT NULL IDENTITY(1,1),
    EnrolmentId INT NOT NULL,
    FinishTime TIME(0) NOT NULL,
    PositionOverall INT NULL,
    PositionCategory INT NULL,
    RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    RecordedByUserId INT NOT NULL,
    Notes NVARCHAR(500) NULL,
    CONSTRAINT PK_Results PRIMARY KEY (ResultId),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) REFERENCES Enrolments(EnrolmentId),
    CONSTRAINT FK_Results_Users FOREIGN KEY (RecordedByUserId) REFERENCES Users(UserId),
    CONSTRAINT UQ_Results_EnrolmentId UNIQUE (EnrolmentId),
    CONSTRAINT CK_Results_PositionOverall CHECK (
        PositionOverall IS NULL OR PositionOverall > 0
    ),
    CONSTRAINT CK_Results_PositionCategory CHECK (
        PositionCategory IS NULL OR PositionCategory > 0
    )
);

SET IDENTITY_INSERT Roles ON;

INSERT INTO Roles (RoleId, RoleName) VALUES
(1, N'Organiser'),
(2, N'Participant');

SET IDENTITY_INSERT Roles OFF;

SET IDENTITY_INSERT Users ON;

INSERT INTO Users (
    UserId,
    Email,
    PasswordHash,
    FirstName,
    LastName,
    PhoneNumber,
    CreatedAt,
    IsActive
) VALUES
(1, N'organiser1@raceday.co.za', N'$2a$11$samplehashorganiser1',
 N'Sipho', N'Mokoena', N'0821110001', SYSUTCDATETIME(), 1),
(2, N'organiser2@raceday.co.za', N'$2a$11$samplehashorganiser2',
 N'Lerato', N'Ndlovu', N'0821110002', SYSUTCDATETIME(), 1),
(3, N'participant1@raceday.co.za', N'$2a$11$samplehashparticipant1',
 N'Thabo', N'Khumalo', N'0822220001', SYSUTCDATETIME(), 1),
(4, N'participant2@raceday.co.za', N'$2a$11$samplehashparticipant2',
 N'Aisha', N'Patel', N'0822220002', SYSUTCDATETIME(), 1);

SET IDENTITY_INSERT Users OFF;

INSERT INTO UserRoles (UserId, RoleId) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2);

SET IDENTITY_INSERT Events ON;

INSERT INTO Events (
    EventId,
    Name,
    Description,
    EventDate,
    StartTime,
    Location,
    RouteDescription,
    MaxParticipants,
    CreatedByUserId,
    IsPublished
) VALUES
(1, N'Cape Town 10K Classic',
 N'Flat coastal 10 km road race along the Atlantic seaboard.',
 '2026-04-12', '07:00:00',
 N'Sea Point, Cape Town',
 N'Sea Point Promenade to Camps Bay and back.',
 5000, 1, 1),

(2, N'Joburg City Half Marathon',
 N'Urban half marathon through Johannesburg CBD and suburbs.',
 '2026-05-24', '06:30:00',
 N'Mary Fitzgerald Square, Johannesburg',
 N'CBD loop via Maboneng and Newtown.',
 8000, 1, 1),

(3, N'Durban Sunrise Cycle Challenge',
 N'Morning cycling event along the Golden Mile and harbour route.',
 '2026-06-14', '05:30:00',
 N'North Beach, Durban',
 N'North Beach to uShaka and back via the promenade.',
 2000, 2, 1);

SET IDENTITY_INSERT Events OFF;

INSERT INTO Categories (
    EventId,
    Name,
    DistanceKm,
    EntryFee,
    MinAge,
    MaxAge,
    MaxEntries
) VALUES
(1, N'Open 10K', 10.00, 250.00, 16, 99, 3000),
(1, N'Junior 5K', 5.00, 150.00, 12, 15, 500),
(1, N'Veterans 10K', 10.00, 220.00, 40, 99, 800),
(2, N'Open Half', 21.10, 350.00, 16, 99, 5000),
(2, N'Walk 10K', 10.00, 200.00, 16, 99, 1500),
(3, N'40K Sportive', 40.00, 300.00, 18, 99, 1200),
(3, N'20K Fun Ride', 20.00, 180.00, 14, 99, 600);

INSERT INTO Enrolments (
    UserId,
    CategoryId,
    EnrolmentDate,
    BibNumber,
    Status,
    EmergencyContact
) VALUES
(3, 1, DATEADD(DAY, -10, SYSUTCDATETIME()), N'CT10K-001',
 N'Confirmed', N'0829990001'),

(3, 4, DATEADD(DAY, -5, SYSUTCDATETIME()), N'JHBHM-014',
 N'Confirmed', N'0829990001'),

(4, 1, DATEADD(DAY, -8, SYSUTCDATETIME()), N'CT10K-002',
 N'Confirmed', N'0829990002'),

(4, 6, DATEADD(DAY, -3, SYSUTCDATETIME()), N'DUR40-007',
 N'Confirmed', N'0829990002'),

(4, 2, DATEADD(DAY, -2, SYSUTCDATETIME()), N'CT5K-003',
 N'Confirmed', N'0829990002');

INSERT INTO Results (
    EnrolmentId,
    FinishTime,
    PositionOverall,
    PositionCategory,
    RecordedByUserId,
    Notes
) VALUES
(1, '00:52:18', 145, 120, 1, N'Strong finish on a windy day.'),
(3, '00:48:55', 78, 65, 2, N'Personal best attempt.');

PRINT 'RaceDay database created and seeded successfully.';
```
