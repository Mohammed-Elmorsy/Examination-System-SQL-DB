--exam generation
alter proc exam_generation @crs_name varchar(20),@tf int,@mcq int
,@duration int
as
if exists(select crs_id from course where crs_name = @crs_name)
begin
	declare @crs_id int,@qid int
	declare @counter_tf int,@counter_mcq int
	select @counter_tf=1,@counter_mcq=1
	select @crs_id =crs_id from course where crs_name = @crs_name
	insert into exam values(@crs_id,@duration)
	declare @exam_id int
	set @exam_id=@@IDENTITY;

	while(@counter_tf<=@tf)
	begin
	select top(1)@qid=ques_id from question where crs_id=@crs_id 
	and type='T or F' and ques_id 
	not IN(
	select ques_id from question_exam where exam_id=@exam_id) order by NEWID()
	insert into question_exam values(@exam_id,@qid)
	set @counter_tf=@counter_tf+1
	end
	while(@counter_mcq<=@mcq)
	begin
	select top(1)@qid=ques_id from question where crs_id=@crs_id 
	and type='MCQ' and ques_id 
	not IN(
	select ques_id from question_exam where exam_id=@exam_id) order by NEWID()
	insert into question_exam values(@exam_id,@qid)
	set @counter_mcq=@counter_mcq+1
	end
end

exam_generation 'c#',4,6,120
exam_generation 'html',5,5,90
exam_generation 'sql',7,3,120
exam_generation 'c#',4,6,120
-------------------------------------------------------------------------------
--exam answers
alter proc st_answer @exid int,@stname varchar(50),@ans1 varchar(1)
,@ans2 varchar(1),@ans3 varchar(1),@ans4 varchar(1)
,@ans5 varchar(1),@ans6 varchar(1),@ans7 varchar(1)
,@ans8 varchar(1),@ans9 varchar(1),@ans10 varchar(1)
as
declare @st_id int,@old_exam int,@crs_id int
select @st_id= st_id from student where st_fname=@stname
select @crs_id = crs_id from exam where exam_id = @exid
select @old_exam=exam.exam_id from exam inner join st_exam_question on
exam.exam_id=st_exam_question.exam_id where st_id=@st_id and exam.crs_id=@crs_id
 
if exists(select exam_id from exam where exam_id=@exid) 
begin
	if exists(select st_id from student where st_fname=@stname)
	begin
		if exists(select st_exam_question.exam_id from exam inner join st_exam_question on
        exam.exam_id=st_exam_question.exam_id where st_id=@st_id and exam.crs_id=@crs_id ) 
		begin
			--delete the last exam of this student in the same course
			delete from st_exam_question where exam_id = @old_exam and st_id=@st_id
			update  student_grade set grade=0 where crs_id = @crs_id and st_id=@st_id
		end
			declare @i int=1
			declare @st varchar(50)
			declare @temp varchar(10)
			set @st=@ans1+@ans2+@ans3+@ans4+@ans5+@ans6+@ans7+@ans8+@ans9+@ans10
			declare s cursor
				for select ques_id from question_exam where exam_id=@exid
				for update
			declare @ques_id int
			open s
			fetch s into @ques_id
			begin
				While @@fetch_status=0  
				begin
					select @temp=substring(@st,@i,1)
					insert into st_exam_question (st_id,exam_id,ques_id,st_answer) 
					values(@st_id,@exid,@ques_id,@temp)
					select @i=@i +1
					fetch s into @ques_id
				end
			end
		close s
		deallocate s
	end
	else 
		select 'invalid student id'
end
else
	select 'invalid exam id'
return

st_answer 1009,'dina','F','T','T','T','B','C','T','F','D','C'
st_answer 1012,'dina','F','T','F','A','B','C','T','F','D','C'
st_answer 1011,'ali','B','C','B','A','B','C','T','F','D','C'

------------------------------------------------------------------------------
--exam correction
alter proc exam_correction @exam_id int,@st_name varchar(20)
as
declare @st_id int,@crs_id int
select @st_id = st_id from student where st_fname = @st_name
select @crs_id = crs_id from exam where exam_id = @exam_id
if exists(select st_id from st_exam_question where st_id = @st_id
and exam_id = @exam_id)
begin
	declare @degree float = 0
	declare s cursor
		for select ques_id, st_answer from st_exam_question where exam_id = @exam_id 
		and st_id = @st_id
		for update
	declare @ques_id int, @answer varchar(1)
	open s
	fetch s into @ques_id,@answer
	begin
		While @@fetch_status=0  
		begin	
			if((select model_answer from question where ques_id = @ques_id) = @answer)
			begin
				set @degree = @degree + 1
			end	
			fetch s into  @ques_id,@answer
		end
	end
	close s
	deallocate s

	declare @crs_grade float
	set @crs_grade = (@degree*100/10)
	update student_grade set grade=@crs_grade where st_id=@st_id and crs_id=@crs_id
end
else
	select 'invalid input'

exam_correction 1012,'dina'
exam_correction 1011,'ali'
----------------------------------------------------------------------------------