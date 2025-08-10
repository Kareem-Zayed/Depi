create database Company02

use Company02

create table Employee
(
SSN int primary key identity ,
BirthDate date ,
Gender varchar(1),
FName varchar (20),
LName varchar (20),
Dnum int
)

CREATE TABLE Department (
    DNum INT PRIMARY KEY,
    DName NVARCHAR(100) NOT NULL,
    SSN INT NOT NULL, 
    HiringDate DATE NOT NULL,
    FOREIGN KEY (SSN) REFERENCES Employee(SSN)
)

CREATE TABLE Project (
    PNumber INT PRIMARY KEY,
    PName NVARCHAR(100) NOT NULL,
    LocationCity NVARCHAR(50),
    DNum INT NOT NULL,
    FOREIGN KEY (DNum) REFERENCES Department(DNum)
)

CREATE TABLE DeptLocations (
    DNum INT NOT NULL,
    Location NVARCHAR(100) NOT NULL,
    PRIMARY KEY (DNum, Location),
    FOREIGN KEY (DNum) REFERENCES Department(DNum)
)

CREATE TABLE Dependent (
    Name NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    Gender CHAR(1) ,
    SSN INT NOT NULL,
    PRIMARY KEY (Name, SSN),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN)
)

CREATE TABLE Employee_Project (
    PNumber INT NOT NULL,
    SSN INT NOT NULL,
    WorkingHours INT,
    PRIMARY KEY (PNumber, SSN),
    FOREIGN KEY (PNumber) REFERENCES Project(PNumber),
    FOREIGN KEY (SSN) REFERENCES Employee(SSN)
)

ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Department
FOREIGN KEY (DNum) REFERENCES Department(DNum);

INSERT INTO Employee VALUES
(1, '1990-05-12', 'M', 'Ahmed', 'Ali', 1),
(2, '1988-11-03', 'F', 'Sara', 'Hassan', 2),
(3, '1995-02-20', 'M', 'Omar', 'Mahmoud', 1),
(4, '1992-07-15', 'F', 'Nora', 'Yousef', 3),
(5, '1998-09-25', 'M', 'Mostafa', 'Kamel', 2);


INSERT INTO Department VALUES
(1, 'IT', 1, '2015-01-10'),
(2, 'HR', 2, '2017-06-20'),
(3, 'Finance', 4, '2018-03-15');


INSERT INTO Project VALUES
(101, 'Website Development', 'Cairo', 1),
(102, 'Recruitment System', 'Giza', 2),
(103, 'Budget Planning', 'Alexandria', 3);


INSERT INTO Employee_Project VALUES
(101, 1, 40),
(101, 3, 35),
(102, 2, 30),
(102, 5, 25),
(103, 4, 40);


INSERT INTO Dependent VALUES
('Ali', '2010-05-12', 'M', 1),
('Mona', '2012-07-15', 'F', 2);


UPDATE Employee
SET DNum = 3
WHERE SSN = 5;


DELETE FROM Dependent
WHERE Name = 'Mona' AND SSN = 2;


SELECT * FROM Employee
WHERE DNum = 1; 


SELECT E.FName, E.LName, P.PName, EP.WorkingHours
FROM Employee E
JOIN Employee_Project EP ON E.SSN = EP.SSN
JOIN Project P ON EP.PNumber = P.PNumber;




