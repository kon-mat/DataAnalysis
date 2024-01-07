CREATE TABLE Calendar (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATE NOT NULL,
    DayOfWeek NVARCHAR(20),
    DayOfMonth INT,
    Month INT,
    Year INT
);

-- Fill the calendar table with data
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2025-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO Calendar (Date, DayOfWeek, DayOfMonth, Month, Year)
    VALUES (
        @StartDate,
        FORMAT(@StartDate, 'dddd'),
        DAY(@StartDate),
        MONTH(@StartDate),
        YEAR(@StartDate)
    );

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;
