
create database university_sarah
--1.--------------------------------------------------------------------------------------------------------------------------------------
create table Students_tbl
(
student_id int not null primary key clustered,
student_first_name varchar(20),
student_last_name varchar(25),
student_city varchar(25),
student_date_start datetime default getdate()
)

create table Departments_tbl
(
department_id int not null primary key clustered identity(10,10),
department_name varchar(20),
department_head_name varchar(25),
)

create table Courses_tbl
(
course_id int not null primary key clustered identity(11,10),
course_name varchar(30),
course_points int ,
department_id int not null foreign key (department_id) references departments_tbl,
course_start_date datetime default getdate(),
course_end_date datetime default getdate()
)

create table Register_tbl
(
register_id int not null primary key clustered identity(12,10),
student_id int not null foreign key (student_id) references Students_tbl ,
course_id int not null foreign key (course_id) references Courses_tbl,
course_term datetime default getdate(),
register_test_grade int 
)
--2----------------------------------------------------------------------------------------------------------------------------------------------
alter table Courses_tbl
add course_passing_grade int 

alter table  Register_tbl
add course_class_term varchar(1)

--dml
--1-----------------------------------------------------------------------------------------------------------------------------------------------
--Students
insert into Students_tbl values(326023306,'Sarah', 'Fenster','Jerusalem','4/11/2023')
insert into Students_tbl values(214429490,'Pnina', 'Hoorvitz','Jerusalem','3/02/2022')
insert into Students_tbl values(326208634,'Shoshana', 'Malul','Tveria','9/12/2021')
--Departments
insert into Departments_tbl values('מדעי הרוח', 'Dr. Alon')
insert into Departments_tbl values('מדעי המחשב', 'Dr. Chen')
insert into Departments_tbl values('מדעי החברה', 'Dr. Gidon')
--Courses
insert into Courses_tbl values('פסיכולוגיה',8,10, '1/1/2022' ,'1/7/2022',56)
insert into Courses_tbl values('sql',5,20, '1/9/2022' ,'9/3/2023',70)
insert into Courses_tbl values('סוציולוגיה',12,30, '5/7/2022' ,'5/7/2023',54)
insert into Courses_tbl values('java',10,20, '1/1/2024' ,'1/6/2024',70)
--Registers
insert into Register_tbl values(326023306,11,'7/6/2024',96,'A')
insert into Register_tbl values(214429490,11,'7/6/2024',90,'B')
insert into Register_tbl values(326208634,11,'7/6/2024',99,'A')
insert into Register_tbl values(214429490,21,'1/8/2023',100,'B')
insert into Register_tbl values(326208634,21,'1/8/2023',73,'B')
insert into Register_tbl values(326023306,41,'9/4/2023',93,'A')
insert into Register_tbl values(326023306,31,'1/8/2023',45,'B')
--2------------------------------------------------------------------------------------------------------------------------------------------------
update [dbo].[Register_tbl]
set [register_test_grade] = [register_test_grade]+5
where course_class_term ='A'and [register_test_grade]<=95
update [dbo].[Register_tbl]
set [register_test_grade] = 100
where course_class_term ='A'and [register_test_grade]>95

--3------------------------------------------------------------------------------------------------------------------------------------------------
delete
from [dbo].[Register_tbl]
where[register_test_grade] < (select [course_passing_grade]
					  from [dbo].[Courses_tbl]c
					  where c.[course_id]=Register_tbl.course_id )
--dql
--1------------------------------------------------------------------------------------------------------------------------------------------------
select top 1 s.student_id,student_first_name,student_last_name
from Students_tbl s join [dbo].[Register_tbl] r on s.student_id=r.student_id
group by s.student_id,student_first_name,student_last_name
order by avg([register_test_grade]) desc

--2------------------------------------------------------------------------------------------------------------------------------------------------
select course_id ,course_name
from Courses_tbl
where course_id not in (select course_id
						from Register_tbl)
--3------------------------------------------------------------------------------------------------------------------------------------------------
select c.course_id ,c.course_name,c.course_points, c2.course_id, c2.course_name,c2.course_points
from Courses_tbl c join Courses_tbl c2 on c.department_id=c2.department_id
where c.course_id!=c2.course_id and c.course_points=c2.course_points

--4------------------------------------------------------------------------------------------------------------------------------------------------
select count(course_id) ,year(course_start_date) 'year',month(course_start_date)'month'
from Courses_tbl
group by year(course_start_date),month(course_start_date)

--5------------------------------------------------------------------------------------------------------------------------------------------------		
select department_name,sum(course_points)
from Departments_tbl d join Courses_tbl c on d.department_id=c.department_id 
where getdate()>course_start_date and getdate()<course_end_date 
group by d.department_id,department_name
having sum(course_points)>10
order by sum(course_points)desc

--6------------------------------------------------------------------------------------------------------------------------------------------------
select s1.student_id
from Students_tbl s1 join Register_tbl r1 on s1.student_id=r1.student_id
where student_city in  (select student_city
						from Students_tbl s join Register_tbl r on s.student_id=r.student_id
						where s1.student_id !=s.student_id and r1.course_id=r.course_id)

--7------------------------------------------------------------------------------------------------------------------------------------------------
select distinct c.course_name
from Courses_tbl c join Courses_tbl c1 on c.course_name=c1.course_name
where c.department_id!=c1.department_id

--8----------------------------------------------------------------------------------------------------------------------------------------  
select c.[course_id],course_name , 'כולם נכשלו'
from Courses_tbl c join Register_tbl r on c.course_id=r.course_id
group by c.[course_id],course_name
having count([student_id])=(select count(*)
										  from Courses_tbl c1 join Register_tbl r1 on c1.course_id=r1.course_id
										  where c1.course_passing_grade>r1.register_test_grade and c1.course_id=c.course_id)
union	
select c.[course_id],course_name , 'כולם הצליחו!'
from Courses_tbl c join Register_tbl r on c.course_id=r.course_id
group by c.[course_id], course_name
having count([student_id])=(select count(*)
						 from Courses_tbl c1 join Register_tbl r1 on c1.course_id=r1.course_id
						 where c1.course_passing_grade<r1.register_test_grade and c.course_id=c1.course_id)
--דרך נוספת
select c.[course_id],[course_name], 'כולם הצליחו!'
from [dbo].[Courses_tbl]c join [dbo].[Register_tbl]r on c.course_id=r.course_id
group by [course_name],c.[course_id],[course_passing_grade]
having [course_passing_grade]< min([register_test_grade])
union 
select c.[course_id],[course_name], 'כולם נכשלו'
from [dbo].[Courses_tbl]c join [dbo].[Register_tbl]r on c.course_id=r.course_id
group by [course_name],c.[course_id],[course_passing_grade]
having [course_passing_grade]> max([register_test_grade])

--9------------------------------------------------------------------------------------------------------------------------------------------------ 
--דרך ראשונה
select course_name
from Courses_tbl
where [course_id] not in (select c.[course_id]
from [dbo].[Courses_tbl]c join [dbo].[Register_tbl]r on c.course_id=r.course_id
group by c.[course_id],[course_passing_grade]
having [course_passing_grade]< min([register_test_grade])
union 
select c.[course_id]
from [dbo].[Courses_tbl]c join [dbo].[Register_tbl]r on c.course_id=r.course_id
group by c.[course_id],[course_passing_grade]
having [course_passing_grade]> max([register_test_grade]))


--דרך שניה
select course_name
from Courses_tbl c join Register_tbl r on c.course_id=r.course_id
group by course_name, [course_passing_grade]
having [course_passing_grade]> min([register_test_grade]) and  [course_passing_grade]< max([register_test_grade])

--10----------------------------------------------------------------------------------------------------------------------------------------------- 

select c.course_name
from Courses_tbl c 
group by c.course_name					
having (select count(distinct c1.department_id)
		from Courses_tbl c1 
		where c.course_name=c1.course_name )= (select count(*)
									          from Departments_tbl)
																		
--11------------------------------------------------------------------------------------------------------------------------------------------------

select d.[department_name]
from [dbo].[Departments_tbl] d 
group by d.[department_name]
having (select count(c.course_name)
		from Courses_tbl c join [dbo].[Departments_tbl] d1 on c.department_id=d1.department_id
		where d.department_name=d1.department_name)= (select count(distinct course_name)
													  from [dbo].[Courses_tbl])

--12-----------------------------------------------------------------------------------------------------------------------------------------------
select student_id,COUNT(*) 
from [dbo].[Register_tbl] r
where [course_id]in (select [course_id]
		   from [dbo].[Register_tbl] r1 
		   where r1.[student_id]= 326208634)
		   group by student_id
	  having COUNT(*)=(select count(*)  
						 from [dbo].[Register_tbl] r2
						 where [student_id]=326208634)   
							





-- Function--Procedure------------------------------------------------------------------------------------------------------------------------------
--1

go
create PROCEDURE P_Students_Names @x varchar	
AS
BEGIN	
	select  [student_first_name]+' '+[student_last_name]student_name 
	from[dbo].[Students_tbl]s join [dbo].[Register_tbl]r on s.student_id=r.student_id 
	join [dbo].[Courses_tbl]c on c.course_id=r.course_id join[dbo].[Departments_tbl]d on d.department_id=c.department_id 
	where DATEDIFF(dd,[student_date_start],getdate())<=30 and [department_name]=@x
	group by [student_first_name]+' '+[student_last_name],s.[student_id]
	having count(r.course_id)>1
	end
	go

	exec P_Students_Names "מדעי הרוח"
	go 

--2
go
create PROCEDURE P_WithX @x int	
AS
BEGIN	
	select distinct s.[student_id]
	from[dbo].[Students_tbl]s join [dbo].[Register_tbl]r on s.student_id=r.student_id 
	where s.[student_id]!=@x and [course_id] in (select [course_id]
							from [dbo].[Students_tbl]s join [dbo].[Register_tbl]r on s.student_id=r.student_id  
							where s.student_id=@x) 
	end
	go

	exec  P_WithX 326023306
	go
	
	--3
	go
create PROCEDURE P_min_max_grade @x int	
AS
BEGIN	
	select [course_id],min([register_test_grade]),max([register_test_grade])
	from [dbo].[Register_tbl]r 
	where [course_id]!=@x
	group by[course_id]
	having min([register_test_grade])= (select min([register_test_grade])
										from [dbo].[Register_tbl]
										where [course_id]=@x) and  max ([register_test_grade])= (select max([register_test_grade])
																								from [dbo].[Register_tbl]
																								where [course_id]=@x) 
	end
	go

	exec  P_min_max_grade 181
	go
