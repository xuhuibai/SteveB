USE db_University_basic;

#		1. Can you please list all the courses that belong to the Comp. Sci. department and have 3 credits?

#-----Answer: 3 rows returned
SELECT course_id, title AS CompSci_courses FROM course
WHERE dept_name = 'Comp. Sci.' AND credits = 3;

#		2. Can you please list all the students who were instructed by Einstein; make sure there are not duplicities	

#-----Answer: 1 row returned
SELECT * FROM student WHERE 
ID = (SELECT ID FROM takes WHERE 
	course_ID = (SELECT course_ID FROM teaches WHERE 
		ID = (SELECT ID FROM instructor WHERE name = 'Einstein'
        )
	)
);

#		3. Can you please list the names of the all the faculty getting the highest salary within the whole university? 

#-----Answer: 1 row returned
SELECT a.*, b.building FROM
		(SELECT name, dept_name, salary FROM instructor WHERE salary = ANY(SELECT max(salary) FROM instructor)) a
INNER JOIN 
department b
ON a.dept_name = b.dept_name;

#		4. Can you please list the names of all the instructors along with the titles of the courses that they teach?

#-----Answer: 16 rows returned
SELECT a.name, b.title as course_title FROM instructor a
LEFT JOIN
	(SELECT distinct b.title, a.id FROM teaches a
	INNER JOIN
	course b
	ON a.course_id = b.course_id) b
ON a.id = b.id;

#		5. Can you please list the names of instructors with salary amounts between $90K and $100K?

#-----Answer: 3 rows returned (Assuming that $90K and $100K are inclusive)
SELECT name FROM instructor WHERE salary BETWEEN 90000 AND 100000;

#		6. Can you please list what courses were taught in the fall of 2009?

#-----Answer: 3 rows returned
SELECT title FROM course  WHERE course_id = ANY(
    SELECT course_id FROM section WHERE semester = 'fall' AND year = 2009
    );

#		7. Can you please list all the courses taught in the spring of 2010?

#-----Answer: 6 rows returned
SELECT title FROM course  WHERE course_id = ANY(
    SELECT course_id FROM section WHERE semester = 'spring' AND year = 2010
    );

#		8. Can you please list all the courses taught in the fall of 2009 or in the spring of 2010.

#-----8 rows returned
SELECT title FROM course  WHERE course_id = ANY(
	 (SELECT course_id FROM section WHERE semester = 'spring' AND year = 2010)
     UNION ALL
     (SELECT course_id FROM section WHERE semester = 'fall' AND year = 2009)
     );

#		9. List the all the courses taught in the fall of 2009 and in the spring of 2010.

#-----Answer: 1 row returned
SELECT title FROM course  WHERE course_id = ANY(
SELECT a.course_id FROM (SELECT course_id FROM section WHERE semester = 'spring' AND year = 2010) a 
INNER JOIN 
(SELECT course_id FROM section WHERE semester = 'fall' AND year = 2009) b
ON a.course_id = b.course_id
);

#		10. List all the faculty along with their salary and department of the faculty who tough a course in 2009

#-----Answer: 5 rows returned
SELECT name, dept_name, salary FROM instructor WHERE id = ANY(
		SELECT ID FROM teaches WHERE year = 2009
        );
        
#		11. Find the average salary of instructors in the Computer Science department.

#-----Answer: 77333.3333
SELECT AVG(salary) AS avg_salary_CompSci FROM instructor WHERE dept_name = 'Comp. Sci.';

#		12. For each department, please find the maximum enrollment, across all sections, in autumn 2009

#-----Answer: 7 rows returned 
#      (only Comp.Sci. and Physics had courses in autumn 2009 with max capacity of 570 and 30 respectively, other 5 departments had no enrollment in autumn 2009)
SELECT a.dept_name, b.max_capacity FROM department a
LEFT JOIN
	(SELECT n.dept_name, SUM(n.capacity) AS max_capacity FROM
			(SELECT b.*, a.capacity FROM classroom a
			INNER JOIN
					(SELECT a.title, a.dept_name, b.* FROM course a
					INNER JOIN 
					(SELECT * FROM section WHERE semester = 'fall' AND year = 2009) b 
					ON a.course_id = b.course_id) b
			ON a.building = b.building AND a.room_number = b.room_number) n
	GROUP BY dept_name
	) b
ON a.dept_name = b.dept_name;



#		13. Get a table displaying a list of all the students with their ID, the name, the name of the department 
#			and the total number of credits along with the courses they have already taken?

#-----Answer: 23 rows returned (assuming that tot_cred includes the credits each student took in 2009 and 2010)
SELECT a.*, b.course_id, b.title FROM student a
LEFT JOIN 
		(SELECT a.ID, a.course_id, b.title FROM takes a 
		INNER JOIN course b ON a.course_id = b.course_id) b
ON a.ID = b.ID;

#		14. Display a list of students in the Comp. Sci. department, along with the course sections, that they have taken in the spring of 2009. 
#		Make sure all courses taught in the spring are displayed even if no student from the Comp. Sci. department has taken it.

#-----Answer: 10 rows returned (All courses taught in spring (2009 & 2010) are listed with name of student who was from Comp.Sci. and took course in 2009 spring only)

SELECT b.*,  a.name AS CS_student_name FROM
	(SELECT a.name, b.ID, b.course_id, b.sec_id FROM (SELECT * FROM student WHERE dept_name = 'Comp. Sci.') a
	INNER JOIN 
			(SELECT ID, course_id, sec_id FROM takes WHERE
			semester_id = 'spring' AND year = 2009) b
			ON a.ID = b.ID
	) a
RIGHT JOIN
	(SELECT a.title, b.* FROM course a
	INNER JOIN 
			(SELECT course_id, sec_id, semester, year FROM section
			WHERE semester = 'spring') b
			ON a.course_id = b.course_id
	) b
ON a.course_id  =  b.course_id AND a.sec_id = b.sec_id;







