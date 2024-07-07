let
   // Create a list of dates starting from 2013-01-01 for 3650 days
   Source = List.Dates(#date(2013, 1, 1), 3650, #duration(1, 0, 0, 0)), 

   // Convert the list into a table
   #"Converted to Table" = Table.FromList(
      Source, 
      Splitter.SplitByNothing(), 
      null, 
      null, 
      ExtraValues.Error
   ), 

   // Rename the column to "Date"
   #"Renamed Columns" = Table.RenameColumns(#"Converted to Table", {{"Column1", "Date"}}), 

   // Change the type of the "Date" column to date
   #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns", {{"Date", type date}}), 

   // Insert Date Key column in the format YYYYMMDD
   #"Inserted Date Key" = Table.AddColumn(
      #"Changed Type", 
      "Date Key", 
      each Date.Year([Date]) * 10000 + Date.Month([Date]) * 100 + Date.Day([Date]), 
      Int64.Type
   ), 

   // Insert Day of Month column
   #"Inserted Day of Month" = Table.AddColumn(
      #"Inserted Date Key", 
      "Day of Month", 
      each Date.Day([Date]), 
      Int64.Type
   ), 

   // Insert Week Day Number column (Monday as 1, Sunday as 7)
   #"Inserted Week Day Number" = Table.AddColumn(
      #"Inserted Day of Month", 
      "Week Day Number", 
      each Date.DayOfWeek([Date], Day.Monday) + 1, 
      Int64.Type
   ), 

   // Insert Week Day column (abbreviated name, e.g., Mon, Tue)
   #"Inserted Week Day" = Table.AddColumn(
      #"Inserted Week Day Number", 
      "Week Day", 
      each Date.ToText([Date], "ddd"), 
      type text
   ), 

   // Insert Year Number column
   #"Inserted Year Number" = Table.AddColumn(
      #"Inserted Week Day", 
      "Year Number", 
      each Date.Year([Date]), 
      Int64.Type
   ), 

   // Insert Year column as text
   #"Inserted Year" = Table.AddColumn(
      #"Inserted Year Number", 
      "Year", 
      each Text.From(Date.Year([Date])), 
      type text
   ), 

   // Insert Quarter Number column
   #"Inserted Quarter Number" = Table.AddColumn(
      #"Inserted Year", 
      "Quarter Number", 
      each Date.QuarterOfYear([Date]), 
      Int64.Type
   ), 

   // Insert Quarter column (e.g., Q1, Q2)
   #"Inserted Quarter" = Table.AddColumn(
      #"Inserted Quarter Number", 
      "Quarter", 
      each "Q" & Text.From(Date.QuarterOfYear([Date])), 
      type text
   ), 

   // Insert Quarter Year column (e.g., Q1 2024)
   #"Inserted Quarter Year" = Table.AddColumn(
      #"Inserted Quarter", 
      "Quarter Year", 
      each "Q" & Text.From(Date.QuarterOfYear([Date])) & " " & Text.From(Date.Year([Date])), 
      type text
   ), 

   // Insert Month Number column
   #"Inserted Month Number" = Table.AddColumn(
      #"Inserted Quarter Year", 
      "Month Number", 
      each Date.Month([Date]), 
      Int64.Type
   ), 

   // Insert Month column (abbreviated name, e.g., Jan, Feb)
   #"Inserted Month" = Table.AddColumn(
      #"Inserted Month Number", 
      "Month", 
      each Date.ToText([Date], "MMM"), 
      type text
   ), 

   // Insert Year Month Number column (e.g., 202401 for January 2024)
   #"Inserted Year Month Number" = Table.AddColumn(
      #"Inserted Month", 
      "Year Month Number", 
      each Date.Year([Date]) * 100 + Date.Month([Date]), 
      Int64.Type
   ), 

   // Insert Month Year column (e.g., Jan 2024)
   #"Inserted Month Year" = Table.AddColumn(
      #"Inserted Year Month Number", 
      "Month Year", 
      each Date.ToText([Date], "MMM") & " " & Text.From(Date.Year([Date])), 
      type text
   ), 

   // Insert Week Number column
   #"Inserted Week Number" = Table.AddColumn(
      #"Inserted Month Year", 
      "Week Number", 
      each Date.WeekOfYear([Date]), 
      Int64.Type
   ), 

   // Insert Week column (e.g., W01, W02)
   #"Inserted Week" = Table.AddColumn(
      #"Inserted Week Number", 
      "Week", 
      each "W" & Number.ToText(Date.WeekOfYear([Date]), "00"), 
      type text
   ), 

   // Insert Week Year column (e.g., W01-2024)
   #"Inserted Week Year" = Table.AddColumn(
      #"Inserted Week", 
      "Week Year", 
      each "W" & Number.ToText(Date.WeekOfYear([Date]), "00") & "-" & Text.From(Date.Year([Date])), 
      type text
   ), 

   // Insert Week Year Order column (e.g., 202401 for first week of 2024)
   #"Inserted Week Year Order" = Table.AddColumn(
      #"Inserted Week Year", 
      "Week Year Order", 
      each Date.Year([Date]) * 100 + Date.WeekOfYear([Date]), 
      Int64.Type
   ), 

   // Adjusted Week Number for ISO week date system
   #"Inserted Week Number Adj." = Table.AddColumn(
      #"Inserted Week Year Order", 
      "Week Number Adj.", 
      each 
         if Number.RoundDown(
            (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
         )
            = 0
         then
            Number.RoundDown(
               (
                  Date.DayOfYear(#date(Date.Year([Date]) - 1, 12, 31))
                     - (Date.DayOfWeek(#date(Date.Year([Date]) - 1, 12, 31), Day.Monday) + 1)
                     + 10
               )
                  / 7
            )
         else if (
            Number.RoundDown(
               (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
            )
               = 53 and (Date.DayOfWeek(#date(Date.Year([Date]), 12, 31), Day.Monday) + 1 < 4)
         )
         then
            1
         else
            Number.RoundDown(
               (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
            ), 
      Int64.Type
   ), 

   // Adjusted Week Year Order for ISO week date system
   #"Inserted Week Year Order Adj." = Table.AddColumn(
      #"Inserted Week Number Adj.", 
      "Week Year Order Adj.", 
      each 
         if Date.Month([Date]) = 1 and [#"Week Number Adj."] > 50 then
            (Date.Year([Date]) - 1) * 100 + [#"Week Number Adj."]
         else if Date.Month([Date]) = 12 and [#"Week Number Adj."] = 1 then
            (Date.Year([Date]) + 1) * 100 + [#"Week Number Adj."]
         else
            Date.Year([Date]) * 100 + [#"Week Number Adj."], 
      Int64.Type
   ), 

   // Insert Day of Year Number column
   #"Inserted Day of Year Number" = Table.AddColumn(
      #"Inserted Week Year Order Adj.", 
      "Day of Year Number", 
      each Date.DayOfYear([Date]), 
      Int64.Type
   ), 

   // Insert Start of Week column (date of the Monday of the current week)
   #"Inserted Start of Week" = Table.AddColumn(
      #"Inserted Day of Year Number", 
      "Start of Week", 
      each Date.StartOfWeek([Date], Day.Monday), 
      type date
   ), 

   // Insert End of Week column (date of the Sunday of the current week)
   #"Inserted End of Week" = Table.AddColumn(
      #"Inserted Start of Week", 
      "End of Week", 
      each Date.EndOfWeek([Date], Day.Monday), 
      type date
   ), 

   // Insert Start of Month column (first date of the current month)
   #"Inserted Start of Month" = Table.AddColumn(
      #"Inserted End of Week", 
      "Start of Month", 
      each Date.StartOfMonth([Date]), 
      type date
   ), 

   // Insert End of Month column (last date of the current month)
   #"Inserted End of Month" = Table.AddColumn(
      #"Inserted Start of Month", 
      "End of Month", 
      each Date.EndOfMonth([Date]), 
      type date
   ), 

   // Insert Start of Quarter column (first date of the current quarter)
   #"Inserted Start of Quarter" = Table.AddColumn(
      #"Inserted End of Month", 
      "Start of Quarter", 
      each Date.StartOfQuarter([Date]), 
      type date
   ), 

   // Insert End of Quarter column (last date of the current quarter)
   #"Inserted End of Quarter" = Table.AddColumn(
      #"Inserted Start of Quarter", 
      "End of Quarter", 
      each Date.EndOfQuarter([Date]), 
      type date
   ), 

   // Insert Start of Year column (first date of the current year)
   #"Inserted Start of Year" = Table.AddColumn(
      #"Inserted End of Quarter", 
      "Start of Year", 
      each Date.StartOfYear([Date]), 
      type date
   ), 

   // Insert End of Year column (last date of the current year)
   #"Inserted End of Year" = Table.AddColumn(
      #"Inserted Start of Year", 
      "End of Year", 
      each Date.EndOfYear([Date]), 
      type date
   ), 

   // Insert Day Type column (classify as "Working day" or "Non-working day")
   #"Inserted Day Type" = Table.AddColumn(
      #"Inserted End of Year", 
      "Day Type", 
      each 
         if Date.DayOfWeek([Date], Day.Monday) = 5 or Date.DayOfWeek([Date], Day.Monday) = 6 then
            "Non-working day"
         else if Date.DayOfWeek([Date], Day.Monday) >= 0 and Date.DayOfWeek([Date], Day.Monday) <= 4 then
            "Working day"
         else
            "Other", 
      type text
   ), 

   // Insert Date Previous Week column (date of the same day in the previous week)
   #"Inserted Date Previous Week" = Table.AddColumn(
      #"Inserted Day Type", 
      "Date Previous Week", 
      each Date.AddDays([Date], - 7), 
      type date
   ), 

   // Insert Date Previous Month column (date of the same day in the previous month)
   #"Inserted Date Previous Month" = Table.AddColumn(
      #"Inserted Date Previous Week", 
      "Date Previous Month", 
      each Date.AddMonths([Date], - 1), 
      type date
   ), 

   // Insert Date Previous Quarter column (date of the same day in the previous quarter)
   #"Inserted Date Previous Quarter" = Table.AddColumn(
      #"Inserted Date Previous Month", 
      "Date Previous Quarter", 
      each Date.AddQuarters([Date], - 1), 
      type date
   ), 

   // Insert Date Previous Year column (date of the same day in the previous year)
   #"Inserted Date Previous Year" = Table.AddColumn(
      #"Inserted Date Previous Quarter", 
      "Date Previous Year", 
      each Date.AddYears([Date], - 1), 
      type date
   ), 

   // Insert Month Days column (number of days in the current month)
   #"Inserted Month Days" = Table.AddColumn(
      #"Inserted Date Previous Year", 
      "Month Days", 
      each Date.DaysInMonth([Date]), 
      Int64.Type
   ), 

   // Insert Quarter Days column (number of days in the current quarter)
   #"Inserted Quarter Days" = Table.AddColumn(
      #"Inserted Month Days", 
      "Quarter Days", 
      each Duration.Days(Date.EndOfQuarter([Date]) - Date.StartOfQuarter([Date])) + 1, 
      Int64.Type
   ), 

   // Insert Year Days column (number of days in the current year)
   #"Inserted Year Days" = Table.AddColumn(
      #"Inserted Quarter Days", 
      "Year Days", 
      each if Date.IsLeapYear(Date.Year([Date])) then 366 else 365, 
      Int64.Type
   )
in
   #"Inserted Year Days"