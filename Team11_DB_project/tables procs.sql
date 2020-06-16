-------------------------------student table -----------------------------------
------select----
create proc std_select @id int
as 
if exists(select st_id from student where st_id=@id)
	select * from student
	where st_id=@id
else
	select 'not found'
std_select 2

------insert-----
alter proc std_insert (@id int ,@fname varchar(20)
,@lname varchar(20),@add varchar(30),@age int,@dept_id int)
as 
begin
if not exists(select st_id from student where st_id=@id)
begin
	if exists(select dept_id from department where dept_id = @dept_id)
	begin
		insert into student
		values(@id,@fname,@lname,@add,@age,@dept_id)
	end
	else
		select 'invalid department id'
end
else
	select 'duplicated student id'
end

std_insert 1,'mohammed','elmorsy','mansoura',26,1,3
std_insert 2,'dina','azmy','kaf_elsheikh',24,2,2
std_insert 4,'noha','zahran','mansoura',25,1,1

------------update----------
create proc std_update (@id int,@fname varchar(20),@lname varchar(20)
,@add varchar(30),@age int,@dept_id int)
as 
if exists(select st_id from student where st_id=@id)
begin
	update student set st_fname= @fname ,st_lname=@lname ,address=@add 
	,age=@age ,dept_id=@dept_id
	where st_id=@id
end
else 
	select 'invalid student id'


std_update  6,'shadia','ahmed','mansoura',24,1
-----------delete -----------
create proc std_delete (@id int)
as
if exists(select st_id from student where st_id=@id)
delete from student where st_id=@id
else 
	select 'invalid student id'

std_delete 6
-----------------------------student course---------------------------------------
--insert
create proc insert_student_course @stid int ,@crid int
as
if exists (select st_id from student where st_id=@stid)
begin
	if exists (select crs_id from course where crs_id=@crid)
	begin
		insert into student_grade (st_id,crs_id)values (@stid,@crid)
	end
	else 
		select 'invalid course id'
end
else
	select 'invalid student id'
-------------------------------------------------------
--select
create proc select_st_course @stid int
as
if exists (select st_id from student where st_id=@stid)
begin
	select *from student_grade where st_id=@stid
end
else
	select 'invalid student id'
------------------------------------------------------------
--update
create proc update_course_student @stid int ,@crsid int
as
if exists (select st_id from student where st_id=@stid)
begin
	if exists (select crs_id from course where crs_id=@crsid)
	begin
		update student_grade set crs_id=@crsid where st_id=@stid
	end
	else 
		select 'invalid course id'
end
else
	select 'invalid student id'
---------------------------------- course table ----------------------------------
--select ---
create proc crs_select @id int
as
if exists(select crs_id from course where crs_id = @id)
begin
	select * from course
	where crs_id = @id 
end
else
	select 'invalid course id'

crs_select 2
------------------------------------
--insert ---
create proc crs_insert @id int,@name varchar(10),@hours int,@ins_id int,@dept_id int
as
if not exists(select crs_id from course where crs_id = @id)
begin
	if exists(select ins_id from instructor where ins_id = @ins_id)
	begin
		if exists(select dept_id from department where dept_id = @dept_id)
		begin
			insert into course
			values(@id,@name,@hours,@ins_id)
			insert into dept_course
			values(@dept_id,@id)
		end
		else
			select 'invalid department id'
	end	
	else
		select 'invalid instructor id'
end
else
	select 'duplicated id' 

crs_insert 4,java,45,3,2
-----------------------------------------------------------------------------
--update ------------
alter proc crs_update @id int,@name varchar(20),@hours int
,@ins_id int,@dept_id int
as
if exists(select crs_id from course where crs_id = @id)
begin
	if exists(select ins_id from instructor where ins_id = @ins_id)
	begin
		if exists(select dept_id from department where dept_id = @dept_id)
		begin
			update course set crs_name = @name, duration = @hours,
			ins_id = @ins_id 
			where crs_id = @id
			update dept_course set crs_id=@id where dept_id = @dept_id
		end
		else
			select'invalid department id'
	end
	else 
		select 'invalid insructor id'
end
else
	select 'invalid course id'

crs_update 4,js,25,1,2
---------------------------------------------------------------------------
--delete -----------

alter proc crs_delete @id int 
as 
if exists(select crs_id from course where crs_id = @id)
begin
	delete from dept_course where crs_id = @id
	delete from course where crs_id = @id
end
else
	select 'invalid course id'

crs_delete 4


-----------------------------------topic table ------------------------------------
----------insert --------
create proc topic_insert @crs_id int, @topic_name varchar(20)
as
if exists(select crs_id from course where crs_id = @crs_id) 
begin
	if not exists(select topic from course_topic where crs_id = @crs_id
	and topic = @topic_name)
	begin 
		insert into course_topic
		values(@crs_id,@topic_name)
	end
	else 
		select 'duplicated topic name for this course'
end
else
	select 'invalid course id'

topic_insert 2,'class'
----------------------------------------------------------------
------select -----------
create proc topic_select @crs_id int
as
if exists(select crs_id from course_topic where crs_id = @crs_id)
	select * from course_topic where crs_id = @crs_id
else
	select 'invalid course id'

topic_select 1
-----------------------------------------------------------------
------update ---------
create proc topic_update @crs_id int ,@old_topic_name varchar(20),@new_topic_name varchar(20)
as
if exists(select crs_id from course_topic where crs_id = @crs_id) 
begin
	if exists(select topic from course_topic where topic = @new_topic_name)
		select 'the topic is already assigned to this course'
	else 
		if exists(select topic from course_topic where topic = @old_topic_name)
		begin
			update course_topic set topic = @new_topic_name
			where crs_id = @crs_id and topic = @old_topic_name	
		end
		else
			select 'the topic you try to update is not assigned to the course'
end
else 
	select 'invalid id' 

topic_update 3,'forms','tables'
-----------------------------------------------------------------
 -- delete -------
create proc topic_delete @crs_id int,@topic_name varchar(20)
as
if exists(select crs_id from course_topic where crs_id = @crs_id)
begin
	if exists(select topic from course_topic where topic = @topic_name 
	and crs_id = @crs_id)
		delete from course_topic where crs_id = @crs_id and topic = @topic_name
	else
		select 'invalid topic name'
end
else
	select 'invalid id'

topic_delete 2,'class'
------------------------------ ----department table ------------------------------
----------select-----
create proc dept_select @id int
as
if exists(select dept_id from department where dept_id = @id)
	select * from department where dept_id = @id
else
	select 'invalid department id'
dept_select 1

---------------------
--insert -----
create proc dept_insert(@dept_id int,@dept_name varchar(100),@mangr_id int)
as
if not exists(select dept_id from department where dept_id = @dept_id)
begin
	if exists(select ins_id from instructor where ins_id = @mangr_id)
	begin
		insert into dbo.department
		values(@dept_id, @dept_name,@mangr_id)
	end
	else
		select 'invalid manager id'
end
else
	select 'duplicated department id'

dept_insert 3, iot,1

---------------------
--delete department
create proc dept_delete @id int
as
if exists(select dept_id from department where dept_id = @id)
	delete from dbo.department where dept_id = @id
else
	select 'invalid department id'

dept_delete 3
---------------------
--update department
create proc dept_update @id int,@name varchar(20),@mgr_id int
as
if exists(select dept_id from department where dept_id = @id)
begin
	update dbo.department set dept_id = @id, dept_name=@name
	where dept_id = @id
end
else
	select 'invalid department id'

-- ------------------------====== INSTRUCTOR ======-------------------------------
-- select Procedure with name
alter proc selectIns @name varchar(50)
as
if exists(select ins_id from instructor where ins_name = @name)
begin
	select ins.ins_id, ins.ins_name, ins.address, ins.dept_id
	from instructor ins
	where ins.ins_name like @name
end
else
	select 'invalid instructor name'

selectIns 'nasr'

-- select Procedure with id
create proc selectInsWithId @id int
as
if exists(select ins_id from instructor where ins_id = @id)
begin
	select ins.ins_id, ins.ins_name, ins.address, ins.dept_id
	from instructor ins
	where ins.ins_id = @id
end
else
	select 'invalid instructor id'

selectInsWithId 1
-- ============ ============ ============ =============== =============== --
-- delete procedure
create proc deleteIns @id int
as
	if exists(select ins_id from instructor where ins_id=@id)
		delete from instructor where ins_id = @id
	else
		select 'Sorry there is no id like that !!'

deleteIns 5
-- ============ ============ ============ =============== =============== --
-- insert procedure
alter proc insertIns @id int, @name varchar(20), @salary int
, @add varchar(30), @did int
as
if not exists(select ins_id from instructor where ins_id = @id)
begin
	if exists(select dept_id from department where dept_id = @did)
		begin
			insert into instructor(ins_id, ins_name, salary, address, dept_id)
			values(@id, @name, @salary, @add, @did)
		end
	else
		select 'invalid department id'
end
else
	select 'invalid instructor id'


insertIns 4, 'Eman', 5000, 'Tanta', 1
-- ============ ============ ============ =============== =============== --
-- update procedure
create proc updateIns @id int, @name varchar(30), @salary int , @add varchar(30), @did int
as
	if exists(select ins_id from instructor where ins_id=@id)
		begin
			if exists(select dept_id from department where dept_id=@did)
				begin
					update instructor
					set ins_name=@name, salary=@salary, address=@add, dept_id=@did
					where ins_id=@id
				end
			else
				select 'invalid department id'
		end
	else
	select 'invalid instructor id'

updateIns 4, 'Eman', 5000, 'Tanta', 2
-- ============ ============ ============ =============== =============== --
-------------------------- Question --------------------------------
----------insert --
create proc INSQuestion @type varchar(20),@description varchar(50),@model varchar(1),@mark int,@cid int
,@chdesc1 varchar(50)=null,@chdesc2 varchar(50)=null
,@chdesc3 varchar(50)=null,@chdesc4 varchar(50)=null
as
if exists(select crs_id from course where crs_id=@cid)
begin
	if(@type='T or F')
		insert into question values(@type,@description,@model,@mark,@cid)
	else if(@type='MCQ')
	begin
		insert into question values(@type,@description,@model,@mark,@cid)
		declare @qid int
		set @qid=@@IDENTITY;
		insert into choices values(@qid,'a',@chdesc1)
		insert into choices values(@qid,'b',@chdesc2)
		insert into choices values(@qid,'c',@chdesc3)
		insert into choices values(@qid,'d',@chdesc4)
	end
	else
	 select 'invalid type'
end
else
	select 'this course does not exist'
return

INSQuestion 'MCQ',' Which statement is wrong about PRIMARY KEY constraint in SQL?','c',2,1,
'The PRIMARY KEY uniquely identifies each record in a SQL database table',
'Primary key can be made based on multiple columns','Primary key must be made of any single columns'
,'Primary keys must contain UNIQUE values'

INSQuestion 'MCQ','  SQL Query to delete all rows in a table without deleting the table (structure, attributes, and indexes)',
'a',1,1,
'DELETE FROM table_name;',
'DELETE TABLE table_name;','DROP TABLE table_name;'
,'NONE'


INSQuestion 'MCQ','Wrong statement about UPDATE keyword is',
'b',1,1,
'If WHERE clause in missing in statement the all records will be updated',
'Only one record can be updated at a time using WHERE clause','Multiple records can be updated at a time using WHERE clause',
'None is wrong statement'

INSQuestion 'MCQ','Correct syntax query syntax to drop a column from a table is',
'c',1,1,
'DELETE COLUMN column_name;','DROP COLUMN column_name;',
'ALTER TABLE table_name DROP COLUMN column_name;',
'None is correct'


INSQuestion 'T or F','The condition in a WHERE clause can refer to only one value',
'f',1,1
--------------- delete ----------

create proc questDelete @quid int
as

if exists(select ques_id from question where ques_id=@quid)and not exists 
(select ques_id from question_exam where ques_id=@quid)
begin
	declare @type varchar(20)
select @type =question.type from question where ques_id=@quid
if(@type='T or F')
	delete from question where ques_id=@quid
else
	begin
		delete from choices where ques_id=@quid
		delete from question where ques_id=@quid
	end
end
else
 select 'this question does not exists'
return

questDelete 1;
questDelete 6;
----------------- update ----------
--update mark ----
create proc updateMark @qid int,@mark int
as
if exists(select ques_id from question where ques_id=@qid)
begin
 update question set mark=@mark where ques_id=@qid
end
else
select 'this question does not exists'
return

updateMark 7,1
------------ update question Course --------
create proc updatequesCourse @qid int,@cid int
as
if exists(select ques_id from question where ques_id=@qid)
begin
if exists(select crs_id from course where crs_id=@cid)
begin
 update question set crs_id=@cid where ques_id=@qid
end
else
select 'this course does not exists'
end
else
select 'this question does not exists'
return

updatequesCourse 2,1
------------- update answer ---------
create proc updateAnswer @qid int,@answer varchar(1)
as
if exists(select ques_id from question where ques_id=@qid)
begin
 update question set model_answer=@answer where ques_id=@qid
end
else
select 'this question does not exists'
return

updateAnswer 2,'a'
------------update choice -------------
create proc updatechoice @qid int ,@choice varchar(10),@text varchar(50)
as
if exists(select ques_id from choices where ques_id=@qid and choice_num=@choice)
begin
update choices set choice_desc=@text where ques_id=@qid and choice_num=@choice
end
else
select 'invalid inpute'
return
---------------update question ----------
create proc updateQuestion @qid int, @type varchar(20),@description varchar(50),@model varchar(1),@mark int,@cid int
,@chdesc1 varchar(50)=null,@chdesc2 varchar(50)=null
,@chdesc3 varchar(50)=null,@chdesc4 varchar(50)=null
as
if exists(select ques_id from question where ques_id=@qid)
begin
if exists(select crs_id from course where crs_id=@cid)
begin
	if(@type='T or F')
		update question set question.type=@type,
		description=@description,model_answer=@model,
		mark=@mark,crs_id=@cid 
		where ques_id=@qid
	else if(@type='MCQ')
	begin
		update question set question.type=@type,
		description=@description,model_answer=@model,
		mark=@mark,crs_id=@cid 
		where ques_id=@qid
		update choices set choice_desc=@chdesc1 where ques_id=@qid and choice_num='a'
		update choices set choice_desc=@chdesc2 where ques_id=@qid and choice_num='b'
		update choices set choice_desc=@chdesc3 where ques_id=@qid and choice_num='c'
		update choices set choice_desc=@chdesc4 where ques_id=@qid and choice_num='d'
	end
	else
	 select 'invalid type'
end
else
	select 'this course does not exist'
end
else
	select 'this question does not exist'
return

 updateQuestion 2, 'msq','  SQL Query to delete all rows in a table without deleting the table (structure, attributes, and indexes)',
'a',1,1,
'DELETE FROM table_name;',
'DELETE TABLE table_name;','DROP TABLE table_name;'
,'NONE'

 updateQuestion 8,'T or F','The condition in a WHERE clause can refer to only one value',
'f',1,1
----------------- select -----------------

create proc selectqueChoices @qid int
as
if exists(select ques_id from question where ques_id=@qid)
begin
select type,description,model_answer,a,b,c,d from
(select ch.ques_id,type,description,model_answer,choice_num,choice_desc
from question as q inner join choices as ch on q.ques_id=ch.ques_id where q.ques_id=@qid)temp
pivot(
max(choice_desc)
for choice_num in(a,b,c,d)
)piv
end
else
select 'question is not exist'
return

selectqueChoices 7
----------select question -------
create proc select_que @qid int
as
if exists(select ques_id from question where ques_id=@qid)
begin
select description,model_answer from question where ques_id=@qid
end
else
select 'question is not exist'
return

---------select choice -----------
create proc select_choice @qid int
as
if exists(select ques_id from question where ques_id=@qid)
begin
select choice_num,choice_desc from choices where ques_id=@qid
end
else
select 'question is not exist'
return

select_choice 2