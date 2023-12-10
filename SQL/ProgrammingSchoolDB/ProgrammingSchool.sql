# --===============[ TWORZENIE TABEL ]===============--

CREATE TABLE lecturer (
	lecturer_id INT AUTO_INCREMENT,
	pesel VARCHAR(11),
	first_name VARCHAR(40) NOT NULL,
	last_name VARCHAR(40) NOT NULL,
	salary INT NOT NULL,
	degree VARCHAR(40),
	PRIMARY KEY (lecturer_id)
	);

CREATE TABLE course (
	course_id INT AUTO_INCREMENT,
	technology VARCHAR(40) NOT NULL,
	level VARCHAR(40) NOT NULL,
	lecturer_id INT,
	PRIMARY KEY (course_id),
	FOREIGN KEY (lecturer_id) REFERENCES lecturer(lecturer_id)
	ON DELETE SET NULL
	);

CREATE TABLE computer (
	computer_id INT AUTO_INCREMENT,
	mac_adress VARCHAR(17),
	system_type VARCHAR(40),
	cpu VARCHAR(40) NOT NULL,
	gpu VARCHAR(40) NOT NULL,
	ram VARCHAR(10) NOT NULL,
	PRIMARY KEY (computer_id)
	);

CREATE TABLE student (
	student_id INT AUTO_INCREMENT,
	pesel VARCHAR(11),
	first_name VARCHAR(40) NOT NULL,
	last_name VARCHAR(40) NOT NULL,
	PRIMARY KEY (student_id)
	);

CREATE TABLE didactic_material (
	material_id INT AUTO_INCREMENT,
	isbn VARCHAR(13),
	technology VARCHAR(40) NOT NULL,
	name VARCHAR(100) NOT NULL,
	type VARCHAR(40) NOT NULL,
	borrower_id INT,
	PRIMARY KEY (material_id),
	FOREIGN KEY (borrower_id) REFERENCES student(student_id)
	ON DELETE SET NULL
	);

CREATE TABLE exam (
	course_id INT,
	student_id INT,
	exam_grade INT NOT NULL,
	PRIMARY KEY (
		course_id,
		student_id
		),
	FOREIGN KEY (course_id) REFERENCES course(course_id)
	ON DELETE CASCADE,
	FOREIGN KEY (student_id) REFERENCES student(student_id)
	ON DELETE CASCADE
	);

CREATE TABLE attend_course (
	student_id INT,
	course_id INT,
	grade INT,
	computer_id INT,
	PRIMARY KEY (
		student_id,
		course_id
		),
	FOREIGN KEY (student_id) REFERENCES student(student_id)
	ON DELETE CASCADE,
	FOREIGN KEY (course_id) REFERENCES course(course_id)
	ON DELETE CASCADE,
	FOREIGN KEY (computer_id) REFERENCES computer(computer_id)
	ON DELETE SET NULL
	);

# --===============[ DODAWANIE REKORDOW ]===============--

INSERT INTO lecturer (
	pesel,
	first_name,
	last_name,
	salary,
	degree
	)
VALUES (
	'65081496175',
	'Jan',
	'Kowalski',
	15000,
	'prof. dr hab. inż.'
	),
	(
	'71020481777',
	'Andrzej',
	'Nowak',
	8900,
	'dr'
	),
	(
	'78032915728',
	'Beata',
	'Strzelczyk',
	11200,
	'dr inż.'
	),
	(
	'86122085143',
	'Ewelina',
	'Wiśniewska',
	7400,
	'mgr inż.'
	);

INSERT INTO course (
	technology,
	LEVEL,
	lecturer_id
	)
VALUES (
	'C#',
	'Beginner',
	4
	),
	(
	'C#',
	'Intermediate',
	2
	),
	(
	'C#',
	'Advanced',
	2
	),
	(
	'JavaScript',
	'Beginner',
	4
	),
	(
	'JavaScript',
	'Intermediate',
	2
	),
	(
	'JavaScript',
	'Advanced',
	2
	),
	(
	'Python',
	'Beginner',
	1
	),
	(
	'Python',
	'Intermediate',
	1
	),
	(
	'Python',
	'Advanced',
	1
	),
	(
	'Java',
	'Beginner',
	4
	),
	(
	'Java',
	'Intermediate',
	3
	),
	(
	'Java',
	'Advanced',
	3
	),
	(
	'Data Science',
	'Beginner',
	1
	),
	(
	'Data Science',
	'Intermediate',
	1
	),
	(
	'Data Science',
	'Advanced',
	1
	),
	(
	'Automated Testing',
	'Beginner',
	4
	),
	(
	'Automated Testing',
	'Intermediate',
	3
	),
	(
	'Automated Testing',
	'Advanced',
	3
	);

INSERT INTO computer (
	mac_adress,
	system_type,
	cpu,
	gpu,
	ram
	)
VALUES (
	'58:61:bc:89:3e:ae',
	'Windows 11',
	'AMD Ryzen 9 5900X',
	'NVIDIA GeForce GTX 1650',
	'32 GB'
	),
	(
	'cd:58:69:97:07:54',
	'Windows 11',
	'AMD Ryzen 9 5900X',
	'NVIDIA GeForce GTX 1650',
	'32 GB'
	),
	(
	'24:63:f8:36:4c:d2',
	'Windows 11',
	'AMD Ryzen 9 5900X',
	'NVIDIA GeForce GTX 1650',
	'32 GB'
	),
	(
	'44:b4:22:36:e7:e8',
	'Windows 11',
	'AMD Ryzen 9 5900X',
	'NVIDIA GeForce GTX 1650',
	'32 GB'
	),
	(
	'ec:77:4e:c6:e5:05',
	'Windows 10',
	'AMD Ryzen 5 5600X',
	'NVIDIA GeForce GTX 1060',
	'32 GB'
	),
	(
	'4a:da:82:33:ac:3e',
	'Windows 10',
	'AMD Ryzen 5 5600X',
	'NVIDIA GeForce GTX 1060',
	'32 GB'
	),
	(
	'ab:01:55:d8:4b:d4',
	'Windows 10',
	'AMD Ryzen 5 5600X',
	'NVIDIA GeForce GTX 1060',
	'32 GB'
	),
	(
	'96:fb:95:11:78:29',
	'Windows 10',
	'AMD Ryzen 5 5600X',
	'NVIDIA GeForce GTX 1060',
	'32 GB'
	),
	(
	'3c:d1:65:dc:35:b3',
	'Windows 10',
	'AMD Ryzen 5 5600X',
	'NVIDIA GeForce GTX 1050',
	'16 GB'
	),
	(
	'f3:30:89:75:95:15',
	'Windows 10',
	'AMD Ryzen 9 5900X',
	'NVIDIA GeForce GTX 1050',
	'16 GB'
	),
	(
	'3d:29:95:d8:16:6c',
	'Linux',
	'Intel Core i9-13900K',
	'NVIDIA GeForce GTX 1050',
	'16 GB'
	),
	(
	'8c:65:6d:bc:bf:7b',
	'Linux',
	'Intel Core i9-13900K',
	'NVIDIA GeForce GTX 1050',
	'16 GB'
	),
	(
	'87:63:dd:5d:ea:3b',
	'Linux',
	'Intel Core i9-13900K',
	'NVIDIA GeForce GTX 1050',
	'16 GB'
	),
	(
	'9c:0a:1b:74:90:4a',
	'Linux',
	'Intel Core i9-13900K',
	'NVIDIA GeForce GTX 1050',
	'16 GB'
	),
	(
	'aa:49:68:01:e1:be',
	'Linux',
	'Intel Core i9-13900K',
	'NVIDIA GeForce GTX 1050',
	'16 GB'
	);

INSERT INTO student (
	pesel,
	first_name,
	last_name
	)
VALUES (
	'94021981572',
	'Daniel',
	'Wójcik'
	),
	(
	'01322964919',
	'Marcel',
	'Krajewski'
	),
	(
	'01270241496',
	'Jarosław',
	'Wasilewski'
	),
	(
	'90071043576',
	'Konrad',
	'Kaźmierczak'
	),
	(
	'89082146587',
	'Danuta',
	'Urbańska'
	),
	(
	'90011776441',
	'Luiza',
	'Mazur'
	),
	(
	'90032324652',
	'Denis',
	'Borkowski'
	),
	(
	'91010228946',
	'Maja',
	'Mazurek'
	),
	(
	'92033016226',
	'Amanda',
	'Zielińska'
	),
	(
	'92080269943',
	'Stefania',
	'Baran'
	),
	(
	'93010519871',
	'Leonardo',
	'Kowalczyk'
	),
	(
	'93041572676',
	'Kuba',
	'Adamski'
	),
	(
	'93110737728',
	'Danuta',
	'Szymczak'
	),
	(
	'94011675694',
	'Olgierd',
	'Wójcik'
	),
	(
	'94020919129',
	'Marcelina',
	'Maciejewska'
	),
	(
	'94052174981',
	'Justyna',
	'Kucharska'
	),
	(
	'94062556856',
	'Klaudiusz',
	'Sikorska'
	),
	(
	'95020877798',
	'Maurycy',
	'Szymański'
	),
	(
	'96010318679',
	'Korneliusz',
	'Zalewski'
	),
	(
	'96022775657',
	'Natan',
	'Kucharski'
	),
	(
	'96060588938',
	'Ksawery',
	'Czarnecki'
	),
	(
	'96072437873',
	'Paweł',
	'Dąbrowski'
	),
	(
	'96082057513',
	'Daniel',
	'Czerwiński'
	),
	(
	'96090963372',
	'Igor',
	'Mróz'
	),
	(
	'97070433915',
	'Jarosław',
	'Jankowski'
	),
	(
	'97120541348',
	'Natasza',
	'Pietrzak'
	),
	(
	'98032474193',
	'Kamil',
	'Maciejewski'
	),
	(
	'98061627458',
	'Julian',
	'Borkowski'
	),
	(
	'99080249397',
	'Ignacy',
	'Kołodziej'
	),
	(
	'99082228749',
	'Klaudia',
	'Brzezińska'
	);

INSERT INTO didactic_material (
	isbn,
	technology,
	name,
	type
	)
VALUES (
	'0-4994-4754-9',
	'C#',
	'C#. Rusz głową! ',
	'Książka'
	),
	(
	'0-3670-5766-2',
	'JavaScript',
	'JavaScript. Przewodnik. ',
	'Książka'
	),
	(
	'0-5173-2416-4',
	'Python',
	'Python. Wprowadzenie. Wydanie V',
	'Książka'
	),
	(
	'0-6333-3687-4',
	'Java',
	'Java. Efektywne programowanie.',
	'Książka'
	),
	(
	'0-7127-8240-0',
	'Data Science',
	'Machine learning, Python i data science. Wprowadzenie',
	'Książka'
	),
	(
	'0-1952-3256-9',
	'Automated Testing',
	'Selenium Webdriver with PYTHON',
	'Kurs wideo'
	),
	(
	'0-4576-9052-6',
	'C#',
	'C# Course - OOP',
	'Kurs wideo'
	),
	(
	'0-6204-3466-X',
	'JavaScript',
	'The Modern JavaScript',
	'Kurs wideo'
	),
	(
	'0-8791-5255-9',
	'Python',
	'Python. Zwięzłe kompendium dla programisty',
	'Książka'
	),
	(
	'0-7041-5827-2',
	'Java',
	'Java. Podstawy. Wydanie XII',
	'Książka'
	);

INSERT INTO attend_course (
	student_id,
	course_id,
	computer_id
	)
VALUES (
	1,
	9,
	1
	),
	(
	2,
	11,
	1
	),
	(
	3,
	7,
	1
	),
	(
	4,
	6,
	1
	),
	(
	5,
	17,
	1
	),
	(
	6,
	8,
	1
	),
	(
	7,
	3,
	1
	),
	(
	8,
	1,
	1
	),
	(
	9,
	12,
	2
	),
	(
	10,
	6,
	2
	),
	(
	11,
	18,
	2
	),
	(
	12,
	8,
	2
	),
	(
	13,
	9,
	2
	),
	(
	14,
	13,
	2
	),
	(
	15,
	10,
	1
	),
	(
	16,
	4,
	2
	),
	(
	17,
	11,
	3
	),
	(
	18,
	7,
	2
	),
	(
	19,
	9,
	3
	),
	(
	20,
	4,
	3
	),
	(
	21,
	15,
	2
	),
	(
	22,
	1,
	2
	),
	(
	23,
	5,
	3
	),
	(
	24,
	10,
	3
	),
	(
	25,
	5,
	4
	),
	(
	26,
	6,
	3
	),
	(
	27,
	16,
	3
	),
	(
	28,
	17,
	3
	),
	(
	29,
	15,
	3
	),
	(
	30,
	6,
	4
	),
	(
	1,
	14,
	1
	),
	(
	3,
	13,
	1
	),
	(
	4,
	12,
	1
	),
	(
	7,
	15,
	1
	),
	(
	9,
	2,
	1
	),
	(
	11,
	11,
	2
	),
	(
	12,
	16,
	1
	),
	(
	13,
	5,
	1
	),
	(
	14,
	17,
	2
	),
	(
	16,
	18,
	3
	),
	(
	17,
	3,
	2
	),
	(
	19,
	2,
	2
	),
	(
	20,
	7,
	3
	),
	(
	21,
	8,
	3
	),
	(
	22,
	5,
	2
	),
	(
	23,
	12,
	3
	),
	(
	24,
	1,
	3
	),
	(
	25,
	7,
	4
	),
	(
	26,
	14,
	3
	),
	(
	27,
	5,
	5
	),
	(
	28,
	13,
	3
	),
	(
	29,
	2,
	3
	),
	(
	30,
	17,
	4
	),
	(
	3,
	4,
	1
	),
	(
	9,
	18,
	1
	),
	(
	13,
	14,
	2
	),
	(
	16,
	10,
	2
	),
	(
	19,
	16,
	2
	),
	(
	27,
	3,
	3
	);








  #--===============[ TRIGGERY ]===============--

CREATE TABLE material_loan (
	loan_id INT AUTO_INCREMENT
    ,material_id INT
    ,borrower_id INT
    ,loan_date DATETIME
    ,lending BOOL NOT NULL
	,PRIMARY KEY (loan_id)
	,FOREIGN KEY (material_id) REFERENCES didactic_material(material_id) ON DELETE CASCADE
    ,FOREIGN KEY (borrower_id) REFERENCES student(student_id) ON DELETE CASCADE
	);

DELIMITER $$
CREATE TRIGGER book_loan_upd
    BEFORE UPDATE ON didactic_material
    FOR EACH ROW
    BEGIN
        IF new.borrower_id IS NULL THEN
            INSERT INTO material_loan (
                material_id
                ,borrower_id
                ,loan_date
                ,lending
                )
            VALUES (
                new.material_id
                ,new.borrower_id
                ,sysdate()
                ,FALSE
                );
        ELSEIF new.borrower_id IS NOT NULL THEN
            INSERT INTO material_loan (
                material_id
                ,borrower_id
                ,loan_date
                ,lending
                )
            VALUES (
                new.material_id
                ,new.borrower_id
                ,sysdate()
                ,TRUE
                );
        END IF;
DELIMITER ;



CREATE TABLE completed_course (
	course_id INT
	,student_id INT
	,course_grade INT NOT NULL
	,exam_grade INT
	,complete_date DATETIME
	,PRIMARY KEY (
		course_id
		,student_id
		)
	,FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE
	,FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE
	);

DELIMITER $$
CREATE TRIGGER course_complete
    AFTER UPDATE ON attend_course
    FOR EACH ROW
    BEGIN
        IF new.grade IS NOT NULL THEN
            INSERT INTO completed_course (
                course_id
                ,student_id
                ,course_grade
                ,exam_grade
                ,complete_date
                )
            VALUES (
                new.course_id
                ,new.student_id
                ,new.grade
                ,(
				    SELECT exam_grade
				    FROM exam
				    WHERE course_id = new.course_id
					    AND student_id = new.student_id
				    )
                ,sysdate()
                );
        END IF;
    END;
DELIMITER ;




#--===============[ TESTOWANIE BAZY DANYCH ]===============--

#Wypożyczenie materiału dydaktycznego numer 3 studentowi numer 5
UPDATE didactic_material
SET borrower_id = 5
WHERE material_id = 3;

SELECT *
FROM didactic_material;


#Oddanie materiału dydaktycznego numer 3 przez studenta numer 5
UPDATE didactic_material
SET borrower_id = NULL
WHERE material_id = 3;

SELECT *
FROM didactic_material;


#Historia wypożyczeń
SELECT *
FROM material_loan;





# Wystawienie studentowi numer 1 oceny z egzaminu kursu numer 14
INSERT INTO exam
VALUES (14, 1, 4);

# Wystawienie studentowi numer 3 oceny z egzaminu kursu numer 7
INSERT INTO exam
VALUES (7, 3, 3);

# Wystawienie studentowi numer 7 oceny z egzaminu kursu numer 15
INSERT INTO exam
VALUES (15, 7, 5);

# Wystawienie studentowi numer 9 oceny z egzaminu kursu numer 2
INSERT INTO exam
VALUES (2, 9, 5);

# Wystawienie studentowi numer 9 oceny z egzaminu kursu numer 12
INSERT INTO exam
VALUES (12, 9, 4);

SELECT *
FROM exam;


# Wystawienie studentowi numer 1 oceny końcowej z kursu 14
UPDATE attend_course
SET grade = 4
WHERE course_id = 14 AND student_id = 1;

# Wystawienie studentowi numer 3 oceny końcowej z kursu 4 (bez egzaminu)
UPDATE attend_course
SET grade = 5
WHERE course_id = 4 AND student_id = 3;

# Wystawienie studentowi numer 3 oceny końcowej z kursu 4
UPDATE attend_course
SET grade = 3
WHERE course_id = 7 AND student_id = 3;

# Wystawienie studentowi numer 7 oceny końcowej z kursu 15
UPDATE attend_course
SET grade = 5
WHERE course_id = 15 AND student_id = 7;

# Wystawienie studentowi numer 8 oceny końcowej z kursu 1 (bez egzaminu)
UPDATE attend_course
SET grade = 4
WHERE course_id = 1 AND student_id = 8;

# Wystawienie studentowi numer 9 oceny końcowej z kursu 12
UPDATE attend_course
SET grade = 5
WHERE course_id = 12 AND student_id = 9;

SELECT * FROM attend_course;


DELETE FROM attend_course
WHERE course_id = 14 AND student_id = 1;

DELETE FROM attend_course
WHERE course_id = 4 AND student_id = 3;

DELETE FROM attend_course
WHERE course_id = 7 AND student_id = 3;

DELETE FROM attend_course
WHERE course_id = 15 AND student_id = 7;

DELETE FROM attend_course
WHERE course_id = 1 AND student_id = 8;

DELETE FROM attend_course
WHERE course_id = 12 AND student_id = 9;

SELECT *
FROM completed_course;




#--===============[ FUNKCJE UZYTKOWNIKOW ]===============--

#1.Wyświetla wypożyczone materiały dydaktyczne studenta o określonym imieniu i nazwisku

SELECT dm.name as 'Nazwa',
	dm.type as 'Rodzaj',
	ml.loan_date as 'Data_wypożyczenia'
FROM didactic_material dm
JOIN material_loan ml
	ON dm.material_id = ml.material_id
WHERE ml.borrower_id = (
		SELECT student_id
		FROM student
		WHERE first_name = 'Denis'
			AND last_name = 'Borkowski'
		)
	AND dm.borrower_id = (
		SELECT student_id
		FROM student
		WHERE first_name = 'Denis'
			AND last_name = 'Borkowski'
		);


#2.Wyświetla listę ukończonych kursów przez studenta o określonym imieniu i nazwisku

SELECT CONCAT (
		c.technology,
		' ',
		c.LEVEL
		) AS 'Ukończony_kurs',
	cc.exam_grade AS 'Ocena_z_egzaminu',
	cc.course_grade AS 'Ocena_końcowa',
	cc.complete_date AS 'Data_ukończenia_kursu'
FROM completed_course cc
JOIN course c
	ON cc.course_id = c.course_id
WHERE cc.student_id = (
		SELECT student_id
		FROM student
		WHERE first_name = 'Jarosław'
			AND last_name = 'Wasilewski'
		);

#4.Wyświetla listę kursów na które student o określonym imieniu i nazwisku aktualnie uczestniczy (poczwórny JOIN)

SELECT CONCAT (
		c.technology,
		' ',
		c.LEVEL
		) AS 'Kurs',
	CONCAT (
		l.first_name,
		' ',
		l.last_name
		) AS 'Prowadzący',
	CONCAT (
		'Komputer nr ',
		co.computer_id,
		'; Mac ',
		co.mac_adress
		) AS 'Przypisany_komputer',
	e.exam_grade AS 'Ocena_z_egzaminu'
FROM attend_course ac
JOIN course c
	ON c.course_id = ac.course_id
JOIN lecturer l
	ON c.lecturer_id = l.lecturer_id
JOIN computer co
	ON ac.computer_id = co.computer_id
LEFT JOIN exam e
	ON c.course_id = e.course_id
		AND (
			SELECT student_id
			FROM student
			WHERE first_name = 'Amanda'
				AND last_name = 'Zielińska'
			) = e.student_id
WHERE ac.student_id = (
		SELECT student_id
		FROM student
		WHERE first_name = 'Amanda'
			AND last_name = 'Zielińska'
		);




#3.Wyświetla ilość ukończonych kursów i średnią ocen studenta o określonym imieniu i nazwisku

SELECT CONCAT (
		s.first_name,
		' ',
		s.last_name
		) AS 'Student',
	COUNT(cc.course_grade) AS 'Ilość_ukończonych_kursów',
	AVG(cc.course_grade) AS 'Średnia_ocen_z_ukończonych_kursów'
FROM student s
JOIN completed_course cc
	ON s.student_id = cc.student_id
WHERE s.first_name = 'Jarosław'
	AND s.last_name = 'Wasilewski';




#1.Wyświetla imiona i nazwiska studentów, którzy uczestniczą na zajęcia wykładowcy o określonym imieniu i nazwisku

SELECT
    s.first_name AS 'Imię_studenta',
    s.last_name AS 'Nazwisko_studenta',
    CONCAT(c.technology, ' ', c.level) AS 'Kurs'
FROM
    student s JOIN attend_course ac ON s.student_id = ac.student_id
    JOIN course c ON ac.course_id = c.course_id
WHERE
    c.lecturer_id = (
        SELECT
            lecturer_id
        FROM
            lecturer
        WHERE
            first_name = 'Jan'
            AND last_name = 'Kowalski'
        LIMIT
            1
    );




#2.Wyświetla kursy prowadzone przez wykładowcę o określonym imieniu i nazwisku oraz ilość uczestniczących studentów na dany kurs

SELECT
    CONCAT(c.technology, ' ', c.level) AS 'Kurs',
    COUNT(ac.course_id) AS 'Ilość_studentów'
FROM
    course c JOIN attend_course ac on c.course_id = ac.course_id
WHERE
    c.lecturer_id = (
        SELECT
            lecturer_id
        FROM
            lecturer
        WHERE
            first_name = 'Jan'
            AND last_name = 'Kowalski'
        LIMIT
            1
    )
GROUP BY ac.course_id;







# Funkcja do projektu !!!

CREATE FUNCTION Raport_Studenta (
	student_first_name VARCHAR(40),
	student_last_name VARCHAR(40)
	)
RETURNS VARCHAR(100)	# <= zwracany typ danych
DETERMINISTIC
RETURN (
		SELECT CONCAT (
				s.first_name,
				' ',
				s.last_name,
				'; Ukończone kursy: ',
				COUNT(cc.course_grade),
				'; Średnia: ',
				AVG(cc.course_grade)
				) AS 'Raport_studenta'
		FROM student s
		JOIN completed_course cc ON s.student_id = cc.student_id
		WHERE s.first_name = student_first_name
			AND s.last_name = student_last_name
		);


SELECT Raport_Studenta('Jarosław', 'Wasilewski');