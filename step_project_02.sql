-- Запити
-- 1. Покажіть середню зарплату співробітників за кожен рік, до 2005 року.
select year(from_date) as sal_year, round(avg(salary),0) as avg_salary  from salaries
group by sal_year
having sal_year between min(year(from_date)) and 2005
order by sal_year;

-- 2. Покажіть середню зарплату співробітників по кожному відділу. Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників
select dept_name, round(avg(salary),0) as avg_salary from departments
join dept_emp on dept_emp.dept_no = departments.dept_no and to_date > curdate()
join salaries on salaries.emp_no = dept_emp.emp_no and salaries.to_date > curdate()
group by dept_name
order by avg_salary desc;

-- 3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік
select dept_name, year(salaries.from_date) as sal_year, round(avg(salary), 0) from departments
join dept_emp on dept_emp.dept_no = departments.dept_no
join salaries on salaries.emp_no = dept_emp.emp_no
group by dept_name, sal_year
order by dept_name, sal_year;

-- 4. Покажіть відділи в яких зараз працює більше 15000 співробітників.
select dept_name, count(emp_no) as qnty_staff from departments
join dept_emp on dept_emp.dept_no = departments.dept_no and to_date > curdate()
group by dept_name
having qnty_staff > 15000
order by qnty_staff desc;

-- 5. Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище
with
max_work_period as (select min(hire_date) from employees
					join dept_manager on dept_manager.emp_no = employees.emp_no and to_date > curdate())
select employees.emp_no, dept_name, hire_date, last_name from employees
join dept_manager on dept_manager.emp_no = employees.emp_no and to_date > curdate()
join departments on departments.dept_no = dept_manager.dept_no
where hire_date = (select * from max_work_period);

-- 6. Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.
with
avg_dept_sal as	(select dept_no as depart_no, avg(salary) as depart_avg_sal from salaries
				join dept_emp on dept_emp.emp_no = salaries.emp_no and salaries.to_date > curdate() and dept_emp.to_date > curdate()
				group by dept_no)
select sal.emp_no, depart.dept_no, (salary - depart_avg_sal) as sal_diff from salaries as sal
join dept_emp as depart on depart.emp_no = sal.emp_no and sal.to_date > curdate() and depart.to_date > curdate()
join avg_dept_sal on depart.dept_no = avg_dept_sal.depart_no
order by sal_diff desc
limit 10;

-- 7. Для кожного відділу покажіть другого по порядку менеджера. Необхідно вивести відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став менеджером відділу
with
second_manager as (select dept_name, first_name, last_name, hire_date, from_date,  row_number() over ( partition by dept_manager.dept_no order by from_date ) as'mngr_number' from dept_manager
					join employees on employees.emp_no = dept_manager.emp_no
                    join departments on departments.dept_no = dept_manager.dept_no)
select dept_name, first_name, last_name, hire_date, from_date from second_manager
where mngr_number = 2;

-- Дизайн бази даних:
/* 1. Створіть базу даних для управління курсами. База має включати наступні таблиці:
- students: student_no, teacher_no, course_no, student_name, email, birth_date.
- teachers: teacher_no, teacher_name, phone_no
- courses: course_no, course_name, start_date, end_date */
drop database if exists corses_managing;
create database if not exists corses_managing;
use corses_managing;
drop table if exists teachers, courses, students;
create table if not exists teachers (
teacher_no int auto_increment primary key,
teacher_name varchar(35),
phone_no varchar(13)
);
create table if not exists courses (
course_no int auto_increment primary key,
course_name varchar(50),
start_date date,
end_date date
);
create table if not exists students (
student_no int auto_increment primary key,
teacher_no int,
course_no int,
student_name varchar(35),
email varchar(50),
birth_date date,
foreign key (teacher_no) references teachers(teacher_no) on update cascade on delete restrict,
foreign key (course_no) references courses(course_no) on update cascade on delete restrict
);

-- 2. Додайте будь-які данні (7-10 рядків) в кожну таблицю.
start transaction;
	insert	into courses(course_no, course_name, start_date, end_date)
	values
	(1, 'MS SQL Server', '2023-10-01', '2023-11-15'),
	(2, 'MySQL Server', '2023-10-02', '2023-11-16'),
	(3, 'PostgreSQL', '2023-10-03', '2023-11-17'),
	(4, 'Oracle SQL', '2023-10-04', '2023-11-18'),
	(5, 'Python', '2023-10-05', '2023-11-19'),
	(6, 'Tableau', '2023-10-06', '2023-11-20'),
	(7, 'Power BI', '2023-10-07', '2023-11-21'),
	(8, 'Excel', '2023-10-08', '2023-11-22'),
	(9, '1c', '2023-10-09', '2023-11-23');
	insert into teachers(teacher_no, teacher_name, phone_no)
	values
	(1, 'Kazuhito Cappelletti', '+380661001010'),
	(2, 'Cristinel Bouloucos', '+380661001011'),
	(3, 'Kazuhide Peha', '+380661001012'),
	(4, 'Lillian Haddadi', '+380661001013'),
	(5, 'Mayuko Warwick', '+380661001014'),
	(6, 'Ramzi Erde', '+380661001015'),
	(7, 'Shahaf Famili', '+380661001016'),
	(8, 'Bojan Montemayor', '+380661001017'),
	(9, 'Suzette Pettey', '+380661001018');
	insert into students(student_no, teacher_no, course_no, student_name, email, birth_date)
	values
	(1, 5, 8, 'Georgi Facello', 'georgi_facello@gmail.com', '1998-06-26'),
	(2, 6, 9, 'Bezalel Simmel', 'bezalel_simmel@gmail.com', '2003-11-21'),
	(3, 7, 4, 'Parto Bamford', 'parto_bamford@gmail.com', '1998-08-28'),
	(4, 3, 9, 'Chirstian Koblick', 'chirstian_koblick@gmail.com', '1998-12-01'),
	(5, 9, 3, 'Kyoichi Maliniak', 'kyoichi_maliniak@gmail.com', '1999-09-12'),
	(6, 1, 1, 'Anneke Preusig', 'anneke_preusig@ukr.net', '1999-06-02'),
	(7, 2, 2, 'Tzvetan Zielinski', 'tzvetan_zielinski@ukr.net', '1999-02-10'),
	(8, 3, 3, 'Saniya Kalloufi', 'saniya_kalloufi@ukr.net', '1994-09-15'),
	(9, 4, 4, 'Sumant Peac', 'sumant_peac@ukr.net', '2003-02-18'),
	(10, 5, 5, 'Duangkaew Piveteau', 'duangkaew_piveteau@ukr.net', '1999-08-24'),
	(11, 6, 6, 'Mary Sluis', 'mary_sluis@meta.ua', '1990-01-22'),
	(12, 7, 7, 'Patricio Bridgland', 'patricio_bridgland@meta.ua', '1992-12-18'),
	(13, 8, 8, 'Eberhardt Terkki', 'eberhardt_terkki@bing.com', '2003-10-20'),
	(14, 9, 9, 'Berni Genin', 'berni_genin@bing.com', '2002-03-11'),
	(15, 4, 6, 'Guoxiang Nooteboom', 'guoxiang_nooteboom@bing.com', '2002-07-02');
commit;

-- 3. По кожному викладачу покажіть кількість студентів з якими він працював
select teacher_name, count(student_no) as qnty_students from teachers 
join students on students.teacher_no = teachers.teacher_no
group by teacher_name
order by qnty_students desc;

-- 4. Спеціально зробіть 3 дубляжі в таблиці students (додайте ще 3 однакові рядки)
alter table students
modify student_no int,
drop primary key;
start transaction; 
	insert into students(student_no, teacher_no, course_no, student_name, email, birth_date)
	values
	(1, 5, 8, 'Georgi Facello', 'georgi_facello@gmail.com', '1998-06-26'),
	(1, 5, 8, 'Georgi Facello', 'georgi_facello@gmail.com', '1998-06-26'),
	(1, 5, 8, 'Georgi Facello', 'georgi_facello@gmail.com', '1998-06-26'),
	(1, 5, 8, 'Georgi Facello', 'georgi_facello@gmail.com', '1998-06-26'),
	(2, 6, 9, 'Bezalel Simmel', 'bezalel_simmel@gmail.com', '2003-11-21'),
	(3, 7, 4, 'Parto Bamford', 'parto_bamford@gmail.com', '1998-08-28');
commit;

-- 5. Напишіть запит який виведе дублюючі рядки в таблиці students
with
 DuplicateStudents as (select student_name from students 
						group by student_name
                        having count(student_name) > 1 )
select s.student_no, s.teacher_no, s.course_no, s.student_name, s.email, s.birth_date
from students as s
join DuplicateStudents ds on (s.student_name = ds.student_name)
order by 1;