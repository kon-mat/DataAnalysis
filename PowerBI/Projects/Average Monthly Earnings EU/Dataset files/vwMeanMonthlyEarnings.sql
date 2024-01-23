USE AverageMonthlyEarnings
GO


CREATE VIEW vwMeanMonthlyEarnings
AS

SELECT
	*
FROM
(
	SELECT
		e.DATAFLOW,
		e.LAST_UPDATE,
		tf.TimeFrequency,
		ac.AgeClass,
		ei.EarningsIndicator,
		coo.OccupationClass,
		s.SexLong,
		sc.SizeClass,
		mu.MeasureUnit,
		ge.GeoEntity,
		e.OBS_VALUE,
		e.OBS_FLAG

	FROM
		estat_earn_ses18_21_en e

		LEFT JOIN TimeFrequency tf
			ON e.freq = tf.Freq

		LEFT JOIN AgeClass ac
			ON e.age = ac.Age

		LEFT JOIN EarningsIndicator ei
			ON e.indic_se = ei.Indicator

		LEFT JOIN ClassificationOfOccupations coo
			ON e.isco08 = coo.Isco08

		LEFT JOIN Sex s
			ON e.sex = s.Sex

		LEFT JOIN SizeClass sc
			ON e.sizeclas = sc.Size

		LEFT JOIN MeasureUnit mu
			ON e.unit = mu.Unit

		LEFT JOIN GeopoliticalEntity ge
			ON e.geo = ge.Geo
) e2

WHERE	
	e2.AgeClass != 'Total'
	AND e2.OccupationClass != 'Total'
	AND e2.SexLong != 'Total'
	AND e2.SizeClass != 'Total'
	AND e2.GeoEntity NOT IN (
		'European Union - 27 countries (from 2020)',
		'Euro area - 17 countries (2011-2013)',
		'Euro area - 18 countries (2014)',
		'European Union - 27 countries (2007-2013)',
		'Euro area - 19 countries (2015-2022)'
	)


