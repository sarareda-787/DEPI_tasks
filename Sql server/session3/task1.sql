--Task 1 – Create the DDL (Data Definition Language) for Company ERD
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


create table dep
(Dnum int primary key,
Dname varchar(50) not null,
ssn int ,
hiring_date date default getdate(),


)

create table proj 
( pnum int primary key,
pname varchar(255) not null,
city varchar(255) default 'cairo',
Dnum int  ,
ssn int )

alter table dep add
constraint c32 foreign key (ssn) references  empt(ssn) 
alter table proj
add constraint c41 foreign key (Dnum) references dep(Dnum) on delete cascade on update cascade ,
    constraint c51 foreign key (ssn) references empt(ssn) 

	create table works_on (
    ssn int,
    pnum int,
    hours int,
	primary key (ssn,pnum),
   foreign key(ssn) references emp(ssn)  ,
   foreign key (pnum) references proj(pnum) on delete cascade on update cascade
    
)
drop table works_on


create table Dep_location(
    Dnum int ,
	loca varchar(255),
	constraint c6 primary key (Dnum, loca ),
	
	)
	alter table Dep_location 
	add constraint c411 foreign key (Dnum) references dep(Dnum) on delete cascade on update cascade

create table depend (
ssn int ,
Dname varchar(255) unique,
primary key (ssn,Dname ),
foreign key (ssn) references empt(ssn) on delete cascade on update cascade
)

--Demonstrate ALTER TABLE usage by:
--Adding a new column

alter table empt 
add  salary int
--Adding a FOREIGN KEY constraint

alter table dep add
constraint c32 foreign key (ssn) references  empt(ssn) 
alter table proj
add constraint c41 foreign key (Dnum) references dep(Dnum) on delete cascade on update cascade ,
    constraint c51 foreign key (ssn) references empt(ssn) 

--Modifying a column's data type

alter table empt 
add  salary bigint

--Dropping an existing constraint

alter table empt
drop constraint c21