CREATE DATABASE EMPLOYEE_PAYROLL;

USE EMPLOYEE_PAYROLL;

CREATE TABLE Employees (
    employee_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    employee_name VARCHAR(255) NOT NULL,
    department VARCHAR(100),
    position VARCHAR(100),
    hire_date DATE,
    base_salary DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Attendance (
    attendance_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    employee_id INT,
    attendance_date DATE,
    Status VARCHAR(10) CHECK (Status IN ('Present', 'Absent', 'Leave')),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Salaries (
    salary_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    employee_id INT,
    base_salary DECIMAL(10, 2) NOT NULL,
    bonus DECIMAL(10, 2),
    deductions DECIMAL(10, 2),
    month VARCHAR(20),
    year INT,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
); 

CREATE TABLE Payroll (
    payroll_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    employee_id INT,
    total_salary DECIMAL(10, 2),
    payment_date DATE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

INSERT INTO Employees (employee_name, department, position, hire_date, base_salary) VALUES 
('Alan Vince', 'Finance', 'Manager', '2020-01-15', 50000.00),
('Alex Kent', 'HR', 'HR Specialist', '2019-03-10', 40000.00);
INSERT INTO Attendance (employee_id, attendance_date, status) VALUES 
(1, '2023-09-01', 'Present'),
(2, '2023-09-01', 'Leave');
INSERT INTO Salaries (employee_id, base_salary, bonus, deductions, month, year) VALUES 
(1, 50000.00, 5000.00, 2000.00, 'September', 2023),
(2, 40000.00, 3000.00, 1000.00, 'September', 2023);

INSERT INTO Payroll (employee_id, total_salary, payment_date) VALUES 
(1, 53000.00, '2023-09-01'),
(2, 50000.00, '2023-09-01'),
(1, 53000.00, '2023-10-01'),
(2, 50000.00, '2023-10-01');

--Add New Employees
INSERT INTO Employees VALUES 
('Emily Clair', 'Finance', 'Analyst', '2020-01-15', 30000.00);

--Update Employee Information
UPDATE Employees SET department = 'HR',position='HR' WHERE employee_id = 3

--Delete Employee Records
DELETE FROM Employees WHERE employee_id=3

--Track Employee Attendance
--capture attendance
INSERT INTO Attendance (employee_id, attendance_date, status) VALUES 
(1, GETDATE(), 'Present'),
(2, GETDATE(), 'Present');
--fetch attendance record of each user
SELECT * FROM Attendance WHERE employee_id = 2
--get number of days present,leave and abscent
SELECT employee_id,COUNT(CASE WHEN status = 'Present' THEN 1 END) Present,
COUNT(CASE WHEN status = 'Absent' THEN 1 END) Absent,COUNT(CASE WHEN status = 'Leave' THEN 1 END) Leave
FROM Attendance GROUP BY employee_id
--fetch attendance percentage of each user
SELECT employee_id,
ROUND((COUNT(CASE WHEN status = 'Present' THEN 1 END) * 100.0) / CAST(COUNT(DISTINCT attendance_date) AS FLOAT),2) AS attendance_percentage
FROM Attendance GROUP BY employee_id
--based on leave taken,update deduction amount
UPDATE Salaries SET deductions = deductions+(SELECT COUNT(CASE WHEN status = 'Leave' THEN 1 END)*(base_salary/30) FROM Attendance) 
--calculate final salary 
SELECT employee_id,(base_salary-deductions+bonus) salary FROM Salaries
--calculate final salary for particular month
SELECT employee_id,(base_salary-deductions+bonus) salary FROM Salaries WHERE MONTH = 'September' AND YEAR=2023
--Generate Pay Slips
SELECT E.employee_id,E.employee_name,S.base_salary,S.bonus,S.deductions,(S.base_salary-S.deductions+S.bonus) final_salary FROM Employees E LEFT JOIN Salaries S ON E.employee_id = S.employee_id
--payroll report
SELECT e.employee_name, p.total_salary, p.payment_date
FROM Payroll p
JOIN Employees e ON p.employee_id = e.employee_id
WHERE p.payment_date BETWEEN '2023-09-01' AND '2023-09-30';
--List Employees by Department
SELECT * FROM Employees ORDER BY department
--get employees who earn more than 45000
SELECT * FROM Employees WHERE base_salary > 45000
--department wise average salary
SELECT department,ROUND(CAST(AVG(base_salary) AS FLOAT),2) average_salary FROM Employees GROUP BY department
--List Employees with Attendance Status on a Specific Date 
SELECT E.*,A.Status FROM Employees E LEFT JOIN Attendance A ON E.employee_id = A.employee_id WHERE A.attendance_date = '2024-12-20'
--find employee with highest salary
SELECT TOP 1 * FROM Employees ORDER BY base_salary DESC
--department wise highest salary
SELECT department,MAX(base_salary) highest_salary FROM Employees GROUP BY department
--department wise highest salary with the employee detail
SELECT *,MAX(base_salary) OVER(PARTITION BY department ORDER BY base_salary DESC) FROM Employees 
--yearly salary report
select e.employee_id,e.employee_name,sum(s.base_salary-s.deductions+s.bonus) salary from employees e left join Salaries s on e.employee_id = s.employee_id and s.year = 2023 group by e.employee_id,e.employee_name
--List Employees with Deducted Salaries in a Given Month
Select e.employee_id,e.employee_name,sum(s.deductions) from Employees e left join Salaries s on e.employee_id = s.employee_id where s.month = 'January' group by e.employee_id,e.employee_name