--Create the EMPLOYEE table with all constraints

create table empt
(ssn int primary key,
BD date ,
Gender varchar(1) check(Gender='M' or Gender='F') ,
Fname varchar(255) not null,
Lname varchar(255) not null,
Dnum int  ,
super_id int ,
constraint c11 foreign key (Dnum) references dept(Dnum) on delete cascade on update cascade ,
constraint c21 foreign key (super_id) references emp(ssn) on delete cascade on update cascade 

)

--Create the DEPARTMENT table with proper relationships

create table dep
(Dnum int primary key,
Dname varchar(50) not null,
ssn int ,
hiring_date date default getdate(),


)


--Create the PROJECT table

create table proj 
( pnum int primary key,
pname varchar(255) not null,
city varchar(255) default 'cairo',
Dnum int  ,
ssn int )
--Add foreign key constraints between tables

alter table dep add
constraint c32 foreign key (ssn) references  empt(ssn) 
alter table proj
add constraint c41 foreign key (Dnum) references dep(Dnum) on delete cascade on update cascade ,
    constraint c51 foreign key (ssn) references empt(ssn) 
--Insert sample data into EMPLOYEE table (at least 5 employees)
-- Step 2: Insert employees
INSERT INTO empt (ssn, BD, Gender, Fname, Lname, Dnum, super_id) VALUES
(101, '1990-01-01', 'M', 'Ahmed', 'Ali', 1, NULL),
(102, '1988-05-15', 'F', 'Sara', 'Hassan', 2, 101),
(103, '1992-03-10', 'M', 'Omar', 'Youssef', 2, 101),
(104, '1995-07-20', 'F', 'Mona', 'Kamal', 3, NULL),
(105, '1991-12-30', 'M', 'Tarek', 'Nabil', 3, 104);


--Insert sample data into DEPARTMENT table (at least 3 departments)
delete from dept on cascade
INSERT INTO dep (Dnum, Dname,ssn) 
VALUES (1, 'HR',101),
       (2, 'IT',102),
      (3, 'Finance',103)


--Update an employee's department
update empt
set Dnum = 3
where ssn = 101

--Delete a dependent record
delete from empt
where ssn = 103

--Retrieve all employees working in a specific department
select  *
from empt
where Dnum = 2

--Find all employees and their project assignments with working hours
create table works_on (
    ssn int,
    pnum int,
    hours int,
   foreign key(ssn) references emp(ssn),
   foreign key (pnum) references proj(pnum)
)
insert into works_on values(101,
select e.Fname+' '+e.Lname as [full name] , p.pname, w.hours
from empt e
join works_on w on e.ssn = w.ssn
join proj p on p.pnum = w.pnum


INSERT INTO proj (pnum, pname, city, Dnum, ssn) VALUES
(201, 'Website Redesign', 'Cairo', 2, 102),   
(202, 'Payroll System', 'Alexandria', 1, 101),
(203, 'HR Automation', default, 1, 101);      
  
INSERT INTO works_on (ssn, pnum, hours) VALUES
(101, 203, 10),  
(102, 201, 20),  
(103, 201, 15),  
(104, 202, 25),  
(105, 202, 10),  
(105, 203, 5);   




