USE AdvancedTechniques
GO



--	https://www.evanmiller.org/ab-testing/chi-squared.html - kalkulator
--	-----[   TESTY CHI-KWADRAT (WYNIKI BINARNE)   ]-----


--	1. Do test�w z wynikami binarnymi potrzebujemy:
--			wielko�� kohorty, ilo�� u�ytkownik�w ko�cz�cych dany proces i ich udzia� %
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




--	-----[   TESTY T (WYNIKI CI�G�E)   ]-----


--	1. W tym przyk�adzie badamy czy proces wprowadzania wp�ywa na wydatki u�ytkownik�w
--			W przypadku test�w t wymagane jest podanie trzech warto�ci wej�ciowych:
--			�redniej, odchylenia standardowego, liczby obserwacji	
--SELECT
--	a.variant
--	, COUNT(a.user_id) AS [total_cohorted]
--	, AVG(a.amount) AS [mean_amount]
--	, STDEV(a.amount) AS [stdev_amount]
--FROM
--	(
--		-- Rozbicie wszystkich u�ytkownik�w, kt�rzy uko�czyli 'Onboarding' na dwa warianty
--		SELECT
--			ea.variant
--			, ea.user_id

--			-- suma wydanych pieni�dzy (je�li u�ytkownik nie zrobi� �adnego zakupu, to zamieniamy NULL na 0)
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


--	2. W tym przyk�adzie rozszerzamy poprzednie zapytanie i badamy grup�, kt�ra uko�czy�a proces wprowadzania
--SELECT
--	a.variant
--	, COUNT(a.user_id) AS [total_cohorted]
--	, AVG(a.amount) AS [mean_amount]
--	, STDEV(a.amount) AS [stdev_amount]
--FROM
--	(
--		-- Rozbicie wszystkich u�ytkownik�w, kt�rzy uko�czyli 'Onboarding' na dwa warianty
--		SELECT
--			ea.variant
--			, ea.user_id

--			-- suma wydanych pieni�dzy (je�li u�ytkownik nie zrobi� �adnego zakupu, to zamieniamy NULL na 0)
--			, SUM(COALESCE(gp.amount, 0)) AS [amount]

--		FROM
--			exp_assignment ea

--			LEFT JOIN game_purchases gp
--				ON ea.user_id = gp.user_id

--			INNER JOIN game_actions ga
--				ON ea.user_id = ga.user_id
--				-- warunek uko�czenia procesu wprowadzania
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

--	Variant 1 mia� pozytywny wp�yw na ko�czenie przez u�ytkownik�w wprowadzenia do gry,
--	dlatego mo�na go uzna� za sukces. Nie mia� jednak wp�ywu na og�lny poziom wydatk�w w grze.
--	Dodatkowi u�ytkownicy, kt�rzy uko�czyli wprowadzenie w variancie 1, byli mniej sk�onni p�aci� za gr�.



--	-----[   WARTO�CI ODSTAJ�CE   ]-----
--			W testach statystycznych analizuj�cych ci�g�e miary sukcesu u�ywane s� �rednie.
--			Dlatego takie testy s� wra�liwe na wyj�tkowo wysokie lub niskie warto�ci odstaj�ce.
--			Modyfikacja warto�ci odstaj�cy mo�e sprawi�, �e wyniki eksperymentu b�d� bardziej miarodajne.


--	1. Jednym ze sposob�w radzenia sobie z warto�ciami odstaj�cymi ci�g�ej miary sukcesu jest
--			przekszta�cenie pierwotnej miary na wyniki binarne
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
--			Eksperymenty cz�sto s� prowadzone przez kilka tygodni. To oznacza, �e osoby,
--			kt�re zetkn�y si� z eksperymentem wcze�niej, maj� d�u�sze okno czasowe.
--			Maj� zatem wi�cej czasu na podj�cie dzia�a� zwi�zanych z miar� sukcesu.
--			Aby kontrolowa� ten czynnik, mo�na zastosowa� okno czasowe, czyli sta�y okres liczony
--			od przyst�pienia do eksperymentu, i uwzgl�dnia� dzia�ania podj�te tylko w tym oknie


--	1. Wykorzystanie dodatkowej klauzuli ON, aby uwzgl�dni� tylko zakupy zrobione w przedziale 7 dni
--SELECT
--	a.variant
--	, COUNT(a.user_id) AS [total_cohorted]
--	, AVG(a.amount) AS [mean_amount]
--	, STDEV(a.amount) AS [stdev_amount]
--FROM
--	(
--		-- Tabela z u�ytkownikami i ilo�ci� wydanych pieni�dzy przez nich (rozbicie na warianty i filtr 'Onboarding')
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
--			W analiza "przed i po" por�wnywane s� te same lub podobne populacje przed zmian� i po jej wprowadzeniu.
--			Pomiary uzyskane dla populacji przed zmian� s� traktowane jak wyniki grupy kontrolnej.
--			Pomiary przeprowadzane po modyfikacjach s� uznawane za wyniki grupy eksperymentalnej.


--	1. Przydzia� do grup odbywa si� za pomoc� instrukcji CASE i przydzielamy etykiety "pre" i "post"
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

--	-- dobrym nawykiem jest dodanie liczby dni dla ka�dej z grup, aby mie� pewno��, �e kod jest poprawny
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



--	-----[   INNE RODZAJE ANALIZ - ANALIZA EKSPERYMENT�W NATURALNYCH   ]-----
--			Eksperyment natrualny ma miejsce, gdy jednostki maj� styczno�� z innymi do�wiadczeniami w wyniku jakiego� procesu, 
--			kt�ry jest w przybli�eniu losowy. Jedna grupa ma styczno�� z wariantem normalnym (kontrolnym), 
--			a druga ze zmodyfikowanym, przy czym zmiana mo�e mie� pozytywny lub negatywny wp�yw.
--			Najtrudniejsze w analize eksperyment�w natrualnych jest znalezienie podobnych populacji i wykazanie,
--			�e s� one wystarczaj�co podobne, aby mo�na by�o wyci�ga� wnioski na podstawie test�w statystycznych.


--	1. W poni�szym przyk�adzie por�wnujemy dwie grupy (u�ytkownik�w z Kanady i ze Stan�w Zjednoczonych - podobne lokalizacje)
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