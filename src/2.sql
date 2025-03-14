USE student_inf_20231702;

CREATE TABLE Student (
    Sno CHAR(8) PRIMARY KEY,
    Sname VARCHAR(20) NOT NULL,
    Sex CHAR(2),
    Birth DATE,
    Classno VARCHAR(10),
    Entrance_date DATE,
    Home_addr VARCHAR(50)
);

CREATE TABLE Course (
    Cno CHAR(3) PRIMARY KEY,
    Cname VARCHAR(50) NOT NULL,
    Total_perior INT,
    Credit INT
);

CREATE TABLE SC (
    Sno CHAR(8),
    Cno CHAR(3),
    Grade INT,
    PRIMARY KEY (Sno, Cno),
    FOREIGN KEY (Sno) REFERENCES Student(Sno),
    FOREIGN KEY (Cno) REFERENCES Course(Cno)
);

-- a. 添加 Stature 列
ALTER TABLE Student
ADD COLUMN Stature NUMERIC(4, 2) CHECK (Stature < 3.0);

-- b. 添加 Sdept 列
ALTER TABLE Student
ADD COLUMN Sdept VARCHAR(20) NOT NULL;

-- c. 添加 Postcode 列
ALTER TABLE Student
ADD COLUMN Postcode CHAR(6) CHECK (Postcode REGEXP '^[0-9]{6}$');

-- d. 删除 Stature 列
ALTER TABLE Student
DROP COLUMN Stature;


-- a. 入学时间必须在出生年月之后
ALTER TABLE Student
ADD CONSTRAINT CK_Entrance_Birth CHECK (Entrance_date >= Birth);

-- b. 给SC表的成绩Grade列增加默认值约束 (不同数据库实现方式可能不同)
ALTER TABLE SC
ALTER COLUMN Grade SET DEFAULT 0; -- PostgreSQL
-- ALTER TABLE SC ALTER COLUMN Grade SET DEFAULT 0; -- SQL Server

-- c. 删除Grade列的默认值约束
ALTER TABLE SC
ALTER COLUMN Grade DROP DEFAULT; -- PostgreSQL
-- ALTER TABLE SC ALTER COLUMN Grade DROP DEFAULT; -- SQL Server


-- a. 插入实验一的数据 (需要插入你自己的学号)
INSERT INTO Student (Sno, Sname, Sex, Birth, Classno, Entrance_date, Home_addr, Sdept, Postcode) VALUES
('20110001', '张虹', '男', '1992-09-01', '051', '2011-09-01', '南京', '计算机系', '200413'),
('20110002', '林红', '女', '1991-11-12', '051', '2011-09-01', '北京', '计算机系', '100010'),
('20110103', '赵青', '男', '1993-05-11', '061', '2011-09-01', '上海', '软件工程', '200013'),
('20231702', '朱凯年', '男', '2005-02-07', '05Z', '2023-9-11', '月球', '电子魔法', '114514');

INSERT INTO Course (Cno, Cname, Total_perior, Credit) VALUES
('001', '高数', 96, 6),
('002', 'C语言程序设计', 80, 5),
('003', 'JAVA语言程序设计', 48, 3),
('004', 'Visual_Basic', 48, 4);

INSERT INTO SC (Sno, Cno, Grade) VALUES
('20110001', '001', 89),
('20110001', '002', 78),
('20110001', '003', 89),
('20110002', '002', 60),
('20110103', '001', 80),
('20231702', '001', 90); -- 你自己的选课记录

-- b.  insert into Student(Sno, Sname, Sex) values(‘20101101’,’赵青’,’男’),该语句能成功执行吗？为什么？
--   可能无法成功执行，因为Student表中Sname和Sex列被定义为NOT NULL，但是此条SQL语句并没有赋值, 会提示违反非空约束

-- c.  insert into sc values(‘20110103’,’005’,80),该语句能成功执行吗？为什么？
--   可能无法成功执行，因为Course表中没有课程编号005. 违反了外键约束

-- a. 修改Course表中课程号为'002'的学分和总学时
UPDATE Course
SET Credit = 4, Total_perior = 64
WHERE Cno = '002';

-- b. 修改SC表中选修了'002'课程的同学的成绩
UPDATE SC
SET Grade = Grade * 0.8
WHERE Cno = '002';

-- a. 删除选修了“C语言程序设计”的学生的选课记录
DELETE FROM SC
WHERE Cno = (SELECT Cno FROM Course WHERE Cname = 'C语言程序设计');

-- b. 删除所有的学生选课记录
DELETE FROM SC;