-- 1- Return the students information according to Department No parameter.
create proc deptname @deptNum int
as
	select s.*
	from student s
	where s.dept_id = @deptNum
	return

exec deptname 2
-- =========================================

-- 2- Takes the student ID and returns the grades of the student in all courses.
create proc st_grad @std_id int
as
	select sg.grade , c.crs_name
	from student_grade sg inner join course c
		on c.crs_id=sg.crs_id 
			where sg.st_id=@std_id
	return

st_grad 1	---------------------------
select * from student_grade
-- =========================================

-- 3- Takes the instructor ID and returns the name of the courses that he teaches
--	  and the number of student per course.
create proc ins_crs @ins_id int
as
	select crs.crs_name, count(sg.st_id) as Std_per_Course
	from course crs inner join student_grade sg
		on crs.ins_id = @ins_id
	group by crs_name
return

ins_crs 2
-- =========================================

-- 4- Takes course ID and returns its topics   
create proc c_Topic @crs_id int
as
	if exists(select c.crs_id from course c where c.crs_id=@crs_id)
		select t.topic
		from  course_topic t
		where t.crs_id = @crs_id
	else 
		select 'Sorry, there is no id like that'

c_Topic 1
-- =========================================

-- 5- Takes exam number and returns the Questions in it
create proc exam_question @exam_id int
as
if exists(select exam_id from question_exam where exam_id = @exam_id)
	begin
		select qe.*,type, description 
		from question_exam qe inner join question q
			on q.ques_id = qe.ques_id
		where exam_id =@exam_id
	end
else
	select 'invalid exam id'

exam_question 1005
select * from question_exam
select * from question

-- 6- Takes exam number and the student ID then
--    returns the Questions in this exam with the student answers.
create proc student_answers @exam_id int, @st_id int 
as
	if exists(select st_id from st_exam_question where st_id = @st_id)
		begin
			if exists(select exam_id from st_exam_question where exam_id =@exam_id and st_id = @st_id)
				begin
					select * from st_exam_question
					where st_id = @st_id and exam_id = @exam_id
				end
			else
				select 'student did not take that exam '
		end
	else
		select 'invalid student id'

student_answers 1005, 2


