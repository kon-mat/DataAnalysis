CREATE TABLE YearlyCalendar
(
    year_date DATE
);

DECLARE @Rok INT = 1770;

WHILE @Rok <= 2020
BEGIN
    INSERT INTO YearlyCalendar (year_date)
    VALUES (CONVERT(DATE, CONVERT(VARCHAR(4), @Rok) + '-12-31'));

    SET @Rok = @Rok + 1;
END;