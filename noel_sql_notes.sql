# Basic SQL sequence
SELECT col1,col2 COUNT(colx) AS rename_col
SELECT DISTINCT gender
SELECT COUNT(DISTINCT col)    # MIN(), MAX(), COUNT(), SUM(), AVG()
SELECT ROUND(AVG(col), 2)  # round off by 2 dec.
SELECT *    # wildcard * all columns

FROM table1, table2  # can hv 1 or more tables

JOIN # see below if need to join

WHERE col1 BETWEEN xxx AND xxx # condition AND/OR/IN/NOT IN
WHERE col1 = 'xxx' AND gender = 'F'
WHERE col1 >= '1997-01-01' # condition >,<, >=, <=, <>, != 
WHERE col LIKE('Mark%')  # wildcard '%' , single '_'
WHERE col IN (SELECT col FROM tableX WHERE condition)  # IN nested queries
WHERE col EXISTS (SELECT col FROM tableX WHERE condition)  # EXISTS in subqueries returns T/F, so faster than IN
GROUP BY col
HAVING AVG(salary) > 120000  # everything WHERE can do
ORDER BY col ASC # ASC or DESC
LIMIT 10     
############################################################################
# Join - one to many relationship.
SELECT table1.col1, table1.col2, table2.col1 # what col u want to see in new table
or
SELECT t1.col1, t1.col2, t2.col1 # what col u want to see in new table
FROM R_table1 t1  # Alias without 'AS'
JOIN L_table2 t2 ON t1.col1=t2.col1 ; # 'ON primary key cols
JOIN L_table3 t3 ON t1.col1=t2.col1 ; # 'multiple ON is possible
INNER JOIN # =JOIN(by default) both side must hv value to join, cannot NULL
LEFT JOIN  # = LEFT OUTER JOIN: everything on the left even if right is NULL
CROSS JOIN # connect all values 

WHERE conditions
GROUP BY t1.col1  # helps to remove duplicates after JOIN
HAVING conditions
ORDER BY col ASC # ASC or DESC
LIMIT 10     
############################################################################
# Duplicate table, like create and paste
DROP TABLE IF EXISTS n_newtable_name;

CREATE TABLE n_newtable_name(
    dept_name VARCHAR(40) NULL
    emp_no INT(11) NOT NULL,
    dept_no CHAR(4) NULL,
    from_date DATE NOT NULL,
);

INSERT INTO n_newtable_name 
SELECT *
FROM table_tocopyfrom;
############################################################################
# Insert Values.
INSERT INTO n_newtable_name (emp_no, from_date)  # specific col location 
VALUES (999904, '2017-01-01'),                   # what values to insert
       (999907, '2017-01-01');
############################################################################

DELETE FROM table1
WHERE col1 = 'xxx'
############################################################################
# Advance SQL example
# task Subset A UNION Subset B
# In Subset A, assign employees 10000-10020 to manager 110022. 
# In Subset B, assign employees 10021-10031 to manager 110039. 
SELECT 
    A.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no < 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS A  # Subset A
#### below are copy A paste below as B
UNION SELECT 
    B.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no > 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS B; 
############################################################################
# SQL Functions or Stored Procedure 
# Function MUST return 1 value
# Stored Procedure can do many IN and many OUT.
############################################################################
# Example 1: Stored Procedure
DELIMITER $$
CREATE PROCEDURE avg_salary()
BEGIN
SELECT AVG(salary) FROM salaries;  # Query here.
END$$
DELIMITER ;

CALL employees.avg_salary();   # Call standalone command.
#####################
# Example 2: Stored Procedure (user input then sql OUT a new column)
USE employees;
DROP PROCEDURE IF EXISTS emp_avg_salary_out;
DELIMITER $$
CREATE PROCEDURE emp_info(IN p_first_name varchar(255), IN p_last_name varchar(255), OUT p_emp_no integer)
BEGIN
SELECT e.emp_no INTO p_emp_no # MUST hv INTO, if there is IN and OUT, like create variable.
FROM employees e
WHERE e.first_name = p_first_name AND e.last_name = p_last_name;
END$$
DELIMITER ;
# To run, refresh schemas-> stored-procedure->emp_info-> icon-> Output requesting user IN, then OUT as table. 
# Below new tab will pop. Like a initialization. 
set @p_emp_no = 0;   # SQL auto self created variable name or u can pre-define on your own.
call employees.emp_info('*', '*', @p_emp_no); # enters value into variable
select @p_emp_no;   # Print variable
#####################
# Example 1: Functions must hv only 1x return.
# Function has only IN, but dun need to type IN.
# There is 2 RETURNS, one at CREATE RETURN data type, and the other before END RETURN variable name
DELIMITER $$
# CREATE FUNCTION function_name(parameter data_type) RETURN data_type
CREATE FUNCTION emp_info(p_first_name varchar(255), p_last_name varchar(255)) RETURNS decimal(10,2) 
BEGIN
# DECLARE variable_name data_type
DECLARE v_max_from_date date;
DECLARE v_salary decimal(10,2);
SELECT MAX(from_date) INTO v_max_from_date 
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE e.first_name = p_first_name AND e.last_name = p_last_name;

SELECT s.salary INTO v_salary 
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE e.first_name = p_first_name
        AND e.last_name = p_last_name
        AND s.from_date = v_max_from_date;
RETURN v_salary; # RETURN variable name
END$$
DELIMITER ;
# Below is to call the function.
# Since we used SELECT, meaning it can be part of a query, but stored procedure cannot do that.
SELECT EMP_INFO('Aruna', 'Journel');
############################################################################
# Condition using CASE WHEN THEN ELSE END AS
SELECT e.emp_no, e.first_name, e.last_name,
    CASE 
    WHEN MAX(de.to_date) > SYSDATE() THEN 'Is still employed' # SYSDATE() is a function
    WHEN MAX(de.to_date) < SYSDATE() THEN 'Is not employed'
    ELSE 'Not an employee anymore'
    END AS current_employee  # the value from THEN goes into here AS xxxx

FROM employees e
JOIN dept_emp de ON de.emp_no = e.emp_no
GROUP BY de.emp_no
LIMIT 100;







