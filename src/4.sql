-- 1
select * from student where sex='男' and Birth < (select Birth from student where Sname='林红' limit 1);
-- 2
SELECT
    S.Sno,
    S.Sname,
    SC.Cno,
    C.Cname,
    SC.Grade
FROM
    SC
JOIN
    student AS S ON SC.Sno = S.Sno
JOIN
    course AS C ON SC.Cno = C.Cno;
-- 3
SELECT
    S.Sno,
    S.Sname,
    C.Cname,
    SC.Grade
FROM
    SC
JOIN
    student AS S ON SC.Sno = S.Sno
JOIN
    course AS C ON SC.Cno = C.Cno;
-- 4
SELECT
    S.Sno,
    S.Sname
FROM
    SC
JOIN
    student AS S ON SC.Sno = S.Sno
JOIN
    course AS C ON SC.Cno = C.Cno
WHERE
    C.Cname = 'C语言程序设计';
-- 5
SELECT
    S.Sno,
    S.Sname,
    S.Home_addr
FROM
    student AS S
WHERE
    S.Classno = (SELECT Classno FROM student WHERE Sname = '张虹');
-- 6
SELECT
    S.Sno,
    S.Sname
FROM
    student AS S
WHERE
    S.Classno <> '051'
    AND S.Birth < (SELECT MIN(Birth) FROM student WHERE Classno = '051');
-- 7
SELECT
    S.Sname
FROM
    student AS S
WHERE NOT EXISTS (
    SELECT
        C.Cno
    FROM
        course AS C
    WHERE NOT EXISTS (
        SELECT
            *
        FROM
            SC
        WHERE
            SC.Sno = S.Sno
            AND SC.Cno = C.Cno
    )
);
-- 8
SELECT S.Sno, S.Sname
FROM student S
WHERE S.Sno IN (SELECT SC1.Sno
                 FROM SC SC1
                 WHERE NOT EXISTS (SELECT *
                                     FROM SC SC2
                                     WHERE SC2.Sno = '20110002'
                                       AND NOT EXISTS (SELECT *
                                                           FROM SC SC3
                                                           WHERE SC3.Sno = SC1.Sno
                                                             AND SC3.Cno = SC2.Cno)));
-- 9
SELECT
    S.Sno,
    S.Sname,
    C.Cname,
    SC.Grade
FROM
    SC
JOIN
    student AS S ON SC.Sno = S.Sno
JOIN
    course AS C ON SC.Cno = C.Cno;
-- 10
SELECT
    SC.Sno,
    SC.Cno,
    SC.Grade
FROM
    SC
JOIN
    course AS C ON SC.Cno = C.Cno
WHERE
    C.Cname = '高数'
    AND SC.Grade > (SELECT MAX(Grade) FROM SC WHERE Cno = '002')
ORDER BY
    SC.Grade DESC;
-- 11
SELECT
    S.Sno,
    SUM(SC.Grade) AS TotalGrade
FROM
    SC
JOIN
    student AS S ON SC.Sno = S.Sno
WHERE SC.Grade >= 60 
GROUP BY
    S.Sno
HAVING
    COUNT(DISTINCT SC.Cno) >= 3
ORDER BY
    TotalGrade DESC;
-- 12
SELECT
    AVG(SC.Grade) AS AverageGrade
FROM
    SC
WHERE
    SC.Cno LIKE '%3'
GROUP BY
    SC.Cno
HAVING
    COUNT(DISTINCT SC.Sno) > 3;
-- 13
SELECT
    S.Sno,
    S.Sname,
    MAX(SC.Grade) AS MaxGrade,
    MIN(SC.Grade) AS MinGrade
FROM
    SC
JOIN
    student AS S ON SC.Sno = S.Sno
GROUP BY
    S.Sno,S.Sname
HAVING
    MAX(SC.Grade) - MIN(SC.Grade) > 5;
-- 14
SELECT Sno, Cno, Grade
FROM (
    SELECT
        Sno,
        Cno,
        Grade,
        ROW_NUMBER() OVER (PARTITION BY Sno ORDER BY Grade DESC) AS rn
    FROM
        SC
) AS RankedScores
WHERE rn <= 2;
-- 15
CREATE TABLE student_o LIKE student;

INSERT INTO student_o SELECT * FROM student WHERE Sno IN ('20110001', '20110002');
INSERT INTO student_o (Sno, Sname, Sex, Birth, Classno, Entrance_date, Sdept) VALUES ('20260001', '白钰秀', '女', '2008-02-07', '05z', '2026-09-01', '计算机系');
-- a
SELECT * FROM student INTERSECT SELECT * FROM student_o;
-- b
SELECT * FROM student UNION ALL SELECT * FROM student_o;
-- Two
CREATE DATABASE student_info_other;
-- 1
CREATE TABLE student_info_other.student_o LIKE student_info.student_o;
INSERT INTO student_info_other.student_o SELECT * FROM student_info.student_o;
-- 2
SELECT student.* FROM student
INNER JOIN student_info_other.student_o ON student.Sno = student_info_other.student_o.Sno
AND student.Sname = student_info_other.student_o.Sname
AND student.Sex = student_info_other.student_o.Sex
AND student.Birth = student_info_other.student_o.Birth
AND student.Classno = student_info_other.student_o.Classno
AND student.Entrance_date = student_info_other.student_o.Entrance_date
AND student.Home_addr = student_info_other.student_o.Home_addr
AND student.Sdept = student_info_other.student_o.Sdept
AND student.Postcode = student_info_other.student_o.Postcode;
-- 3
SELECT C.*, SC.*
FROM course C
LEFT JOIN SC ON C.Cno = SC.Cno;
-- 4
SELECT S.*, C.*, SC.*
FROM student S
LEFT JOIN SC ON S.Sno = SC.Sno
LEFT JOIN course C ON SC.Cno = C.Cno;
-- o
WITH WeightedGrades AS (
    SELECT
        SC.Sno,
        SUM(SC.Grade * C.Credit) AS WeightedSum,
        SUM(C.Credit) AS TotalCredits
    FROM
        SC
    JOIN
        course AS C ON SC.Cno = C.Cno
    WHERE SC.Grade >= 60 
    GROUP BY
        SC.Sno
),
RankedStudents AS (
    SELECT
        Sno,
        WeightedSum / TotalCredits AS WeightedAverage,
        RANK() OVER (ORDER BY WeightedSum / TotalCredits DESC) AS `Rank`
    FROM
        WeightedGrades
)
SELECT
    S.Sno,
    S.Sname,
    S.Classno,
    R.WeightedAverage
FROM
    RankedStudents AS R
JOIN
    student AS S ON R.Sno = S.Sno
WHERE
    R.`Rank` <= 10; 