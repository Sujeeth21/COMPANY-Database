CREATE DATABASE IF NOT EXISTS COMPANY DEFAULT CHARACTER SET latin1;

use COMPANY;

CREATE TABLE IF NOT exists DEPARTMENT (
	Dname VARCHAR(15) NOT NULL,
    Dnumber INT NOT NULL,
    Mgr_ssn CHAR(9),
    Mgr_start_date VARCHAR(11),
    CONSTRAINT DEPTWPK PRIMARY KEY (Dnumber),
    CONSTRAINT DEPTWSK UNIQUE (Dname)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT exists EMPLOYEE (
	Fname VARCHAR(15) NOT NULL,
    Minit CHAR,
    Lname VARCHAR(15) NOT NULL,                                  
    Ssn CHAR(9),
	Bdate char(15),
    Address VARCHAR(30),
    Sex CHAR,
    Salary DECIMAL(10 , 2 ),
    Super_ssn CHAR(9),
    Dno INT,
    PRIMARY KEY EMPWPK (Ssn),
    CONSTRAINT EMPWDEPTFK FOREIGN KEY (Dno) REFERENCES DEPARTMENT (Dnumber) ON UPDATE CASCADE,
	CONSTRAINT EMPWSUPERFK FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE (Ssn) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


Alter table DEPARTMENT ADD foreign key (Mgr_ssn) references EMPLOYEE(Ssn) ON UPDATE CASCADE;

SET GLOBAL FOREIGN_KEY_CHECKS=0;

SET SQL_SAFE_UPDATES = 0;

UPDATE Employee SET Bdate = STR_TO_DATE(Bdate, "%d-%b-%Y'");

UPDATE DEPARTMENT SET Mgr_start_date = STR_TO_DATE(Mgr_start_date, "%d-%b-%Y'");

select * from employee;

select * from department;

CREATE TABLE IF NOT exists DEPT_LOCATIONS (
	 Dnumber INT NOT NULL,
    Dlocation VARCHAR(15) NOT NULL,
    PRIMARY KEY (Dnumber , Dlocation),
    FOREIGN KEY (Dnumber) REFERENCES DEPARTMENT (Dnumber) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1; 


CREATE TABLE IF NOT exists PROJECT (
	Pname VARCHAR(15) NOT NULL,
    Pnumber INT NOT NULL,
    Plocation VARCHAR(15),
    Dnum INT NOT NULL,
    PRIMARY KEY (Pnumber),
    CONSTRAINT PROJWSK UNIQUE (Pname),
    FOREIGN KEY (Dnum) REFERENCES DEPARTMENT (Dnumber)
) engine=InnoDB DEFAULT CHARSET=latin1; 


CREATE TABLE IF NOT exists WORKS_ON (
	Essn CHAR(9) NOT NULL,
    Pno INT NOT NULL,
    Hours DECIMAL(3 , 1 ) NOT NULL,
    PRIMARY KEY (Essn , Pno),
    CONSTRAINT WO_ESSNWFK FOREIGN KEY (Essn) REFERENCES EMPLOYEE_WORK (Ssn),
    CONSTRAINT WO_PNOWFK FOREIGN KEY (Pno) REFERENCES PROJECT (Pnumber)
) engine=InnoDB DEFAULT CHARSET=latin1; 

SET GLOBAL FOREIGN_KEY_CHECKS=1;

#PART-2

SELECT fname,minit,lname, Ssn, salary 
from EMPLOYEE a,DEPARTMENT b where 
b.dname='research' and b.dnumber=a.dno and a.salary<60000;

#Q.2

select Employee.Fname as 'First Name', Employee.Minit as 'Middle Name', Employee.Lname as 'Last Name', Employee.salary as 'Salary', employee.ssn as 'SSN' 
from employee join department on employee.dno = department.dnumber where
Department.dname = "Research" and employee.salary < 60000;

#Q.3 - Sublime

set @mydepartment:= Research;
select Employee.Fname, Employee.Lname, Employee.salary, department.dname
from Employee join department on employee.dno = department.dnumber
where department.dname = "Research";

#Q.4

select employee.fname as 'First Name', employee.lname as 'Employee Last Name', project.pname as 'Project Name', works_on.hours as 'Hours'
from  employee join works_on on employee.ssn = works_on.essn join project on works_on.pno = project.pnumber 
where employee.fname = "Mike" and employee.Lname = "Henderson";

#Q.5 - To do - watch video

select employee.fname, employee.lname, project.pname, works_on.hours
from  employee join works_on on employee.ssn = works_on.essn join project on works_on.pno = project.pnumber 
where employee.fname = "Mike" and employee.Lname = "Henderson";

#Q.6 - To do - watch video

select department.dname, sum(employee.salary)
from Employee join department on employee.dno = department.dnumber
where department.dname = "Networking";

#Q.7

select department.dname as 'Department Name', count(employee.fname) as 'Number of Employees'
from department join employee on department.dnumber = employee.dno join Dept_locations on employee.dno = Dept_locations.Dnumber  
where dept_locations.Dlocation in ('Houston', 'Dallas', 'Arlington', 'Austin')
group by department.dname
order by department.dname Desc;

#Q.8

select department.dname as 'Department Name', count(employee.ssn) as 'Number of Employees'
from department join employee on department.dnumber = employee.dno 
where employee.ssn in
(select employee.ssn from employee where employee.salary >= 50000)
group by department.dname
order by count(employee.ssn) Desc;

#Q.9 - 

SELECT department.dname as 'Department Name', employee.fname as "First Name", employee.Lname as "Last Name",
(Select count(employee.super_ssn) from employee where employee.super_ssn=department.mgr_ssn) as "Number of Employees", 
(Select sum(employee.salary) from employee where employee.super_ssn=department.mgr_ssn GROUP BY department.Dname) as "Sum of Salaries",
(Select Max(employee.Salary) from employee where employee.super_ssn=department.mgr_ssn GROUP BY department.Dname) as "Highest Salary",
(Select Min(employee.Salary) from employee where employee.super_ssn=department.mgr_ssn GROUP BY department.Dname) as "Lowest Salary"
FROM employee, department
where employee.ssn=department.Mgr_ssn
order by department.dname;


#Q.10

select project.pname as 'Project Name', count(employee.ssn) as 'Number of Employees'
from employee join project on employee.dno = project.dnum
group by project.pname
order by count(employee.ssn) desc;

#Q.11

select employee.fname as 'First Name', employee.lname as 'Last Name', count(employee.Super_ssn) as 'Number of employees'
from department left join employee on department.mgr_ssn = employee.Super_ssn 
group by department.mgr_ssn
order by count(employee.Super_ssn) desc;  

