SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issue_status
SELECT * FROM Members
SELECT * FROM return_status;


-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
INSERT INTO books;
VALUES( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')	

-- Task 2: Update an Existing Member's Address
UPDATE members 
SET member_address = '777 Main st'
WHERE member_id = 'C101'

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_member_id, COUNT(issued_book_name)
FROM issue_status
GROUP BY issued_member_id
ORDER BY COUNT(issued_book_name) DESC

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
DROP TABLE IF EXISTS book_summery;
CREATE TABLE book_summery
as
(
	SELECT issued_book_name, COUNT(issued_id) as book_issued_count
	FROM issue_status
	GROUP BY issued_book_name
	ORDER BY book_issued_count DESC
)
SELECT * FROM book_summery

--  Data Analysis & Findings
--  The following SQL queries were used to address specific questions:
--  Task 7. Retrieve All Books in a Specific Category 'Classic'
SELECT book_title, category
FROM books
WHERE category = 'Classic'

-- Task 8: Find Total Rental Income by Category:

SELECT * FROM books
SELECT * FROM issue_status

WITH results as
(
	SELECT b.category, b.rental_price * COUNT(i.issued_id) as total_rent
	FROM books as b
	JOIN issue_status as i
	ON b.isbn = i.issued_book_isbn
	GROUP BY b.category, b.rental_price 
	ORDER BY b.Category,total_rent DESC
)
SELECT category, SUM(total_rent) as Total
FROM results
GROUP BY category 
ORDER BY 2 desc


 SELECT b.category,
       SUM(b.rental_price) as Rent_price,
	   COUNT(*)
   FROM books as b
   JOIN issue_status as i
   ON b.isbn = i.issued_book_isbn
   GROUP BY category 2024-06-01
   ORDER BY rent_price DESC

-- Task 9: List Members Who Registered in the Last 180 Days
SELECT * FROM members
WHERE reg_date  > CURRENT_DATE - INTERVAL '100 days'

-- Task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT * FROM branch
SELECT * FROM employees

SELECT e.emp_name, b.manager_id, m.emp_name, b.branch_id
FROM employees e
JOIN branch b
ON e.branch_id = b.branch_id
JOIN employees m
ON e.emp_id = m.emp_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7 USD:
CREATE TABLE book_rent
as
(
	SELECT * FROM books
	WHERE rental_price > 7
)

SELECT * FROM
book_rent

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM return_Status
SELECT * FROM issue_status

SELECT i.issued_book_name, r.return_date
FROM issue_status i
LEFT JOIN return_status r
ON i.issued_id = r.issued_id
WHERE r.return_id is null


-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.
SELECT * FROM members
SELECT * FROM issue_status
SELECT * FROM return_status

SELECT i.issued_member_id,m.member_name, i.issued_book_name,i.issued_date, r.return_date,
CURRENT_DATE - DATE(r.return_date) as diff
FROM issue_status i
LEFT JOIN return_status r
ON i.issued_id = r.issued_id  
JOIN members m
ON i.issued_member_id = m.member_id
WHERE CURRENT_DATE - DATE(r.return_date) > 30 or r.return_date is NULL
ORDER BY diff


/* Task 14: Update Book Status on Return (Pending)
   Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).*/
SELECT * FROM books
SELECT * FROM return_status
SELECT * FROM issue_status

ALTER TABLE issue_status
ADD COLUMN status VARCHAR(30)

WITH results as 
(
	SELECT b.book_title, r.return_Date as returndate
	FROM books b
	JOIN issue_status i
	ON b.isbn = issued_book_isbn
	LEFT JOIN return_status r
	ON i.issued_id = r.issued_id
)

UPDATE issue_status
SET status = 'Yes'
WHERE returndate IS NULL



/* Task 15: Branch Performance Report
   Create a query that generates a performance report for each branch, showing the number of books issued,
   the number of books returned, and the total revenue generated from book rentals.*/
SELECT * FROM books
SELECT * FROM branch
SELECT * FROM issue_status
SELECT * FROM return_status
SELECT * FROM employees

SELECT  e.branch_id, COUNT(i.issued_id)as Total_Issued_Book, COUNT(r.return_date) as Total_Book_Returned,
SUM(b.rental_price) as Total_rental_price
FROM books b
LEFT JOIN issue_status i
ON b.isbn = i.issued_book_isbn
JOIN employees e
ON i.issued_emp_id = e.emp_id
LEFT JOIN return_status r
ON i.issued_id = r.issued_id
GROUP BY e.branch_id


/* Task 16: CTAS: Create a Table of Active Members
   Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
   containing members who have issued at least one book in the last 2 months.*/
CREATE TABLE active_members as 
SELECT *
FROM issue_status
WHERE DATE(issued_date) > CURRENT_DATE - INTERVAL'2 Months'










