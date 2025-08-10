CREATE DATABASE Company03
Use Company03


CREATE TABLE Department (
    DNum INT PRIMARY KEY,
    DName NVARCHAR(100) NOT NULL UNIQUE,
    ManagerSSN INT UNIQUE, 
    HiringDate DATE NOT NULL 
);

CREATE TABLE Employee (
    SSN INT PRIMARY KEY,
    BirthDate DATE NOT NULL,
    Gender CHAR(1) NOT NULL ,
    FName NVARCHAR(50) NOT NULL,
    LName NVARCHAR(50) NOT NULL,
    DNum INT NOT NULL,
    FOREIGN KEY (DNum) REFERENCES Department(DNum) 
        ON UPDATE CASCADE
);


ALTER TABLE Department
ADD CONSTRAINT FK_Department_Manager
FOREIGN KEY (ManagerSSN) REFERENCES Employee(SSN)
    ON UPDATE CASCADE
    ON DELETE SET NULL;

CREATE TABLE Project (
    PNumber INT PRIMARY KEY,
    PName NVARCHAR(100) NOT NULL UNIQUE,
    LocationCity NVARCHAR(50) ,
    DNum INT NOT NULL,
    FOREIGN KEY (DNum) REFERENCES Department(DNum)
        ON UPDATE CASCADE
);

CREATE TABLE Dependent (
    DepName NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    Gender CHAR(1) ,
    EmployeeSSN INT NOT NULL,
    PRIMARY KEY (DepName, EmployeeSSN),
    FOREIGN KEY (EmployeeSSN) REFERENCES Employee(SSN)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Employee_Project (
    PNumber INT NOT NULL,
    SSN INT NOT NULL,
    WorkingHours INT ,
    PRIMARY KEY (PNumber, SSN),
    FOREIGN KEY (PNumber) REFERENCES Project(PNumber)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (SSN) REFERENCES Employee(SSN)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


ALTER TABLE Employee
ADD Email NVARCHAR(100) UNIQUE;


ALTER TABLE Employee
ALTER COLUMN Email NVARCHAR(150);

ALTER TABLE Project
ADD ManagerSSN INT NULL;

ALTER TABLE Project
ADD CONSTRAINT FK_Project_Manager
FOREIGN KEY (ManagerSSN) REFERENCES Employee(SSN);


ALTER TABLE Project
DROP CONSTRAINT FK_Project_Manager;


INSERT INTO Department (DNum, DName, ManagerSSN, HiringDate)
VALUES
(1, 'IT', NULL, '2015-01-10'),
(2, 'HR', NULL, '2017-06-20'),
(3, 'Finance', NULL, '2018-03-15');

INSERT INTO Employee (SSN, BirthDate, Gender, FName, LName, DNum, Email)
VALUES
(101, '1990-05-12', 'M', 'Ahmed', 'Ali', 1, 'ahmed.ali@company.com'),
(102, '1988-11-03', 'F', 'Sara', 'Hassan', 2, 'sara.hassan@company.com'),
(103, '1995-02-20', 'M', 'Omar', 'Mahmoud', 1, 'omar.mahmoud@company.com'),
(104, '1992-07-15', 'F', 'Nora', 'Yousef', 3, 'nora.yousef@company.com'),
(105, '1998-09-25', 'M', 'Mostafa', 'Kamel', 2, 'mostafa.kamel@company.com');


UPDATE Department SET ManagerSSN = 101 WHERE DNum = 1;
UPDATE Department SET ManagerSSN = 102 WHERE DNum = 2;
UPDATE Department SET ManagerSSN = 104 WHERE DNum = 3;

INSERT INTO Project (PNumber, PName, LocationCity, DNum)
VALUES
(201, 'Website Development', 'Cairo', 1),
(202, 'Recruitment System', 'Giza', 2),
(203, 'Budget Planning', 'Alexandria', 3);

INSERT INTO Employee_Project (PNumber, SSN, WorkingHours)
VALUES
(201, 101, 40),
(201, 103, 35),
(202, 102, 30),
(202, 105, 25),
(203, 104, 40);

INSERT INTO Dependent (DepName, BirthDate, Gender, EmployeeSSN)
VALUES
('Ali', '2010-05-12', 'M', 101),
('Mona', '2012-07-15', 'F', 102),
('Omar', '2015-09-01', 'M', 105);
