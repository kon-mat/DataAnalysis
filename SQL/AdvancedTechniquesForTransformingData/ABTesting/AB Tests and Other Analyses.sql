USE AdvancedTechniques
GO



--	https://www.evanmiller.org/ab-testing/chi-squared.html - kalkulator
--	-----[   TESTY CHI-KWADRAT (WYNIKI BINARNE)   ]-----


--	1. Do testów z wynikami binarnymi potrzebujemy:
--			wielkoœæ kohorty, iloœæ u¿ytkowników koñcz¹cych dany proces i ich udzia³ %
--SELECT
--	ea.variant
--	, COUNT(ea.user_id) AS [total_cohorted]
--	, COUNT(ga.user_id) AS [completions]
--	, CAST(COUNT(ga.user_id) AS float) / COUNT(ea.user_id) AS [pct_completed]
--FROM	
--	exp_assignment ea

--	LEFT JOIN game_actions ga
--		ON ea.user_id = ga.user_id
--		AND ga.action = 'onboarding complete'

--WHERE
--	ea.exp_name = 'Onboarding'
--GROUP BY
--	ea.variant


--	OUTPUT:
--		variant		total_cohorted	completions		pct_completed
--		variant 1	50275						38280					0.76141223272004
--		control		49897						36268					0.726857326091749

--	Verdict:
--	variant 1 is more successful
--	(p < 0.001)




--	-----[   TESTY T (WYNIKI CI¥G£E)   ]-----


--	1. W tym przyk³adzie badamy czy proces wprowadzania wp³ywa na wydatki u¿ytkowników
--			W przypadku testów t wymagane jest podanie trzech wartoœci wejœciowych:
--			œredniej, odchylenia standardowego, liczby obserwacji	
--SELECT
--	a.variant
--	, COUNT(a.user_id) AS [total_cohorted]
--	, AVG(a.amount) AS [mean_amount]
--	, STDEV(a.amount) AS [stdev_amount]
--FROM
--	(
--		-- Rozbicie wszystkich u¿ytkowników, którzy ukoñczyli 'Onboarding' na dwa warianty
--		SELECT
--			ea.variant
--			, ea.user_id

--			-- suma wydanych pieniêdzy (jeœli u¿ytkownik nie zrobi³ ¿adnego zakupu, to zamieniamy NULL na 0)
--			, SUM(COALESCE(gp.amount, 0)) AS [amount]

--		FROM
--			exp_assignment ea

--			LEFT JOIN game_purchases gp
--				ON ea.user_id = gp.user_id

--		WHERE
--			ea.exp_name = 'Onboarding'
--		GROUP BY
--			ea.variant
--			, ea.user_id
--	) a
--GROUP BY
--	a.variant


--	OUTPUT:
--		variant			total_cohorted	mean_amount		stdev_amount
--		control			49897						3.7812181093	18.9403775275232
--		variant 1		50275						3.6875888612	19.2201943918719

--	Verdict:	  No significant difference


--	2. W tym przyk³adzie rozszerzamy poprzednie zapytanie i badamy grupê, która ukoñczy³a proces wprowadzania
--SELECT
--	a.variant
--	, COUNT(a.user_id) AS [total_cohorted]
--	, AVG(a.amount) AS [mean_amount]
--	, STDEV(a.amount) AS [stdev_amount]
--FROM
--	(
--		-- Rozbicie wszystkich u¿ytkowników, którzy ukoñczyli 'Onboarding' na dwa warianty
--		SELECT
--			ea.variant
--			, ea.user_id

--			-- suma wydanych pieniêdzy (jeœli u¿ytkownik nie zrobi³ ¿adnego zakupu, to zamieniamy NULL na 0)
--			, SUM(COALESCE(gp.amount, 0)) AS [amount]

--		FROM
--			exp_assignment ea

--			LEFT JOIN game_purchases gp
--				ON ea.user_id = gp.user_id

--			INNER JOIN game_actions ga
--				ON ea.user_id = ga.user_id
--				-- warunek ukoñczenia procesu wprowadzania
--				AND ga.action = 'onboarding complete'	

--		WHERE
--			ea.exp_name = 'Onboarding'
--		GROUP BY
--			ea.variant
--			, ea.user_id
--	) a
--GROUP BY
--	a.variant


--	OUTPUT:
--		variant			total_cohorted	mean_amount		stdev_amount
--		control			36268						5.2021462446	22.0489943825925
--		variant 1		38280						4.8430911703	21.8992841017323

--	Verdict:	  control mean is greater

--	Variant 1 mia³ pozytywny wp³yw na koñczenie przez u¿ytkowników wprowadzenia do gry,
--	dlatego mo¿na go uznaæ za sukces. Nie mia³ jednak wp³ywu na ogólny poziom wydatków w grze.
--	Dodatkowi u¿ytkownicy, którzy ukoñczyli wprowadzenie w variancie 1, byli mniej sk³onni p³aciæ za grê.



--	-----[   WARTOŒCI ODSTAJ¥CE   ]-----
--			W testach statystycznych analizuj¹cych ci¹g³e miary sukcesu u¿ywane s¹ œrednie.
--			Dlatego takie testy s¹ wra¿liwe na wyj¹tkowo wysokie lub niskie wartoœci odstaj¹ce.
--			Modyfikacja wartoœci odstaj¹cy mo¿e sprawiæ, ¿e wyniki eksperymentu bêd¹ bardziej miarodajne.


--	1. Jednym ze sposobów radzenia sobie z wartoœciami odstaj¹cymi ci¹g³ej miary sukcesu jest
--			przekszta³cenie pierwotnej miary na wyniki binarne
--SELECT
--	ea.variant
--	,	COUNT(DISTINCT ea.user_id) AS [total_cohorted]
--	, COUNT(DISTINCT gp.user_id) AS [purchasers]
--	, CAST(COUNT(DISTINCT gp.user_id) AS float)
--		/ COUNT(DISTINCT ea.user_id) AS [pct_purchased]
--FROM 
--	exp_assignment ea

--	LEFT JOIN game_purchases gp
--		ON ea.user_id = gp.user_id

--	INNER JOIN game_actions ga
--		ON ea.user_id = ga.user_id
--		AND ga.action = 'onboarding complete'

--WHERE
--	ea.exp_name = 'Onboarding'
--GROUP BY
--	ea.variant


--	OUTPUT:
--		variant		total_cohorted	purchasers	pct_purchased
--		control		36268						4988				0.137531708393074
--		variant 1	38280						4981				0.130120167189133

--	Verdict:
--	control is more successful
--	(p = 0.00296)



--	-----[   OKNA CZASOWE   ]-----
--			Eksperymenty czésto sá prowadzone przez kilka tygodni. To oznacza, ¿e osoby,
--			które zetknê³y siê z eksperymentem wczeœniej, maj¹ d³u¿sze okno czasowe.
--			Maj¹ zatem wiêcej czasu na podjêcie dzia³añ zwi¹zanych z miar¹ sukcesu.
--			Aby kontrolowaæ ten czynnik, mo¿na zastosowaæ okno czasowe, czyli sta³y okres liczony
--			od przyst¹pienia do eksperymentu, i uwzglêdniaæ dzia³ania podjête tylko w tym oknie


--	1. Wykorzystanie dodatkowej klauzuli ON, aby uwzglêdniæ tylko zakupy zrobione w przedziale 7 dni
--SELECT
--	a.variant
--	, COUNT(a.user_id) AS [total_cohorted]
--	, AVG(a.amount) AS [mean_amount]
--	, STDEV(a.amount) AS [stdev_amount]
--FROM
--	(
--		-- Tabela z u¿ytkownikami i iloœci¹ wydanych pieniêdzy przez nich (rozbicie na warianty i filtr 'Onboarding')
--		SELECT
--			ea.variant
--			, ea.user_id
--			, SUM(COALESCE(gp.amount, 0)) AS [amount]
--		FROM
--			exp_assignment ea

--			LEFT JOIN game_purchases gp
--				ON ea.user_id = gp.user_id
--				-- warunek 7 dni od dokonania zakupu
--				AND gp.purch_date <= DATEADD(day, 7, ea.exp_date)

--		WHERE
--			ea.exp_name = 'Onboarding'
--		GROUP BY
--			ea.variant
--			, ea.user_id
--	) a
--GROUP BY
--	a.variant


--	OUTPUT:
--		variant			total_cohorted	mean_amount		stdev_amount
--		control			49897						1.3693823275	5.76633779399891
--		variant 1		50275						1.3516879164	5.61298585809157

--	Verdict:	  No significant difference



--	-----[   INNE RODZAJE ANALIZ - ANALIZA "PRZED I PO"   ]-----
--			W analiza "przed i po" porównywane s¹ te same lub podobne populacje przed zmian¹ i po jej wprowadzeniu.
--			Pomiary uzyskane dla populacji przed zmian¹ s¹ traktowane jak wyniki grupy kontrolnej.
--			Pomiary przeprowadzane po modyfikacjach s¹ uznawane za wyniki grupy eksperymentalnej.


--	1. Przydzia³ do grup odbywa siê za pomoc¹ instrukcji CASE i przydzielamy etykiety "pre" i "post"
--SELECT

--	CASE
--		WHEN gu.created BETWEEN '2020-01-13' AND '2020-01-26'
--			THEN 'pre'
--		WHEN gu.created BETWEEN '2020-01-27' AND '2020-02-09'
--			THEN 'post'
--	END AS [variant]

--	, COUNT(DISTINCT gu.user_id) AS [cohorted]
--	, COUNT(DISTINCT ga.user_id) AS [opted_in]
--	, CAST(COUNT(DISTINCT ga.user_id) AS float)
--		/ COUNT(DISTINCT gu.user_id) AS [pct_optin]

--	-- dobrym nawykiem jest dodanie liczby dni dla ka¿dej z grup, aby mieæ pewnoœæ, ¿e kod jest poprawny
--	, COUNT(DISTINCT gu.created) AS [days]

--FROM
--	game_users gu

--	LEFT JOIN game_actions ga
--		ON gu.user_id = ga.user_id
--		AND ga.action = 'email_optin'

--WHERE
--	gu.created BETWEEN '2020-01-13' AND '2020-02-09'
--GROUP BY
--	CASE
--		WHEN gu.created BETWEEN '2020-01-13' AND '2020-01-26'
--			THEN 'pre'
--		WHEN gu.created BETWEEN '2020-01-27' AND '2020-02-09'
--			THEN 'post'
--	END


--	OUTPUT:
--		variant	cohorted	opted_in	pct_optin						days
--		post		27617			11220			0.406271499438752		14
--		pre			24662			14489			0.587503041115887		14

--Verdict:
--pre is more successful
--(p < 0.001)



--	-----[   INNE RODZAJE ANALIZ - ANALIZA EKSPERYMENTÓW NATURALNYCH   ]-----
--			Eksperyment natrualny ma miejsce, gdy jednostki maj¹ stycznoœæ z innymi doœwiadczeniami w wyniku jakiegoœ procesu, 
--			który jest w przybli¿eniu losowy. Jedna grupa ma stycznoœæ z wariantem normalnym (kontrolnym), 
--			a druga ze zmodyfikowanym, przy czym zmiana mo¿e mieæ pozytywny lub negatywny wp³yw.
--			Najtrudniejsze w analize eksperymentów natrualnych jest znalezienie podobnych populacji i wykazanie,
--			¿e s¹ one wystarczaj¹co podobne, aby mo¿na by³o wyci¹gaæ wnioski na podstawie testów statystycznych.


--	1. W poni¿szym przyk³adzie porównujemy dwie grupy (u¿ytkowników z Kanady i ze Stanów Zjednoczonych - podobne lokalizacje)
SELECT
	ga.country
	, COUNT(DISTINCT ga.user_id) AS [total_cohorted]
	, COUNT(DISTINCT gp.user_id) AS [purchasers]
	, CAST(COUNT(DISTINCT gp.user_id) AS float)
		/ COUNT(DISTINCT ga.user_id) AS [pct_purchased]
FROM
	game_users ga

	LEFT JOIN game_purchases gp
		ON ga.user_id = gp.user_id

WHERE
	ga.country IN ('United States', 'Canada')
GROUP BY
	ga.country


--		OUTPUT:
--	country					total_cohorted	purchasers	pct_purchased
--	Canada					20179						5011				0.248327469151098
--	United States		45012						4958				0.110148404869812

--Verdict:
--Canada is more successful
--(p < 0.001)