--creating the database and using it
CREATE DATABASE LiteraryNexus;

use LiteraryNexus;

--Creating the tables
create table Book (
Book_ID int primary key,
Book_name varchar(100) not null,
Book_genre varchar(100) not null,
ISBN varchar(100) unique CHECK (LEN(ISBN) <= 13)
);

create table Publisher (
Publisher_ID int primary key,
Publisher_Name varchar(100) unique not null
);


create table Author (
Author_ID int primary key,
Author_FirstName varchar(100),
Author_LastName varchar(100),
Author_BirthDate date,
Author_Email varchar(100),
Author_Phone int
);

create table Member (
Member_ID int primary key,
Member_FirstName varchar(100),
Member_LastName varchar(100),
Member_Email varchar(100),
Member_Phone int,
Member_Gender varchar(1) CHECK (LEN(Member_Gender) = 1),
Street_Name varchar(100),
City_ID int,
Districts_ID int
);


create table Book_Vendor (
Book_Vendor_ID int primary key,
Book_Vendor_contact_Name varchar(100),
Book_Vendor_Email varchar(100),
Book_Vendor_Phone int,
Street_Name varchar(100),
City_ID INT,
Dist_ID INT
);

create table Cities (
City_ID int primary key,
City_name varchar(100) unique not null
);

create table Districts (
Districts_ID int primary key,
Districts_name varchar(100) not null,
City_ID int
);

create table Book_Details (
--all are foriegn keys
Book_ID INT,
Author_ID INT,
Publisher_ID INT
);

create table Book_Member_Transaction (
Book_Member_Transaction_ID int primary key,
Transaction_Type varchar(1) DEFAULT 'B' CHECK (LEN(Transaction_Type) = 1) , -- R for return or B for borrow
Transaction_Date date,
Book_Copies_ID int,
Member_ID int,
Book_State_ID int,
);
insert into Book_Member_Transaction values
(5, DEFAULT,'2021-09-09', 2, 1, 1)
select * from Book_Member_Transaction
create table Book_State (
Book_State_ID int primary key,
Book_State_decs VARCHAR(100) not null CHECK (Book_State_decs IN ('NEW', 'LIKE NEW', 'GOOD', 'FAIR', 'POOR', 'DAMAGED', 'UNUSABLE'))
);

insert into Book_State values
(8, 'Unavailable')
select * from Book_State
create table Book_Copies (
Book_Copies_ID int primary key,
Book_ID INT,
Book_Vendor_ID INT,
Received_State INT
);
select * from Member
DELETE From Cities where City_ID = 3;
--The FOREIGN KEYs
ALTER table Member
add FOREIGN KEY (City_ID) references Cities(City_ID) on update cascade on delete set null;
ALTER table Member
add FOREIGN KEY (Districts_ID) references Districts(Districts_ID);

ALTER table Book_Vendor
add FOREIGN KEY (City_ID) references Cities(City_ID);
ALTER table Book_Vendor
add FOREIGN KEY (Dist_ID) references Districts(Districts_ID);

ALTER table Districts
add FOREIGN KEY (City_ID) references Cities(City_ID);

ALTER table Book_Details
add FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID);
ALTER table Book_Details
add FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID);
ALTER table Book_Details
add FOREIGN KEY (Publisher_ID) REFERENCES Publisher(Publisher_ID);

ALTER table Book_Member_Transaction
add FOREIGN KEY (Book_Copies_ID) references Book_Copies(Book_Copies_ID);
ALTER table Book_Member_Transaction
add FOREIGN KEY (Member_ID) references Member(Member_ID);
ALTER table Book_Member_Transaction
add FOREIGN KEY (Book_State_ID) references Book_State(Book_State_ID);

select * from Book_Member_Transaction;

ALTER table Book_Copies
add FOREIGN KEY (Book_ID) references Book(Book_ID);
ALTER table Book_Copies
add FOREIGN KEY (Book_Vendor_ID) references Book_Vendor(Book_Vendor_ID) on delete set NULL;

DELETE 
ALTER table Book_Copies
add FOREIGN KEY (Received_State) references Book_State(Book_State_ID);

--Creating the Views (After filling the data)
CREATE VIEW Responsible_readers AS
SELECT TOP 2
  Member.Member_FirstName,
  Member.Member_LastName,
  COUNT(*) AS Responsible_readers
FROM Book_Member_Transaction BMT
JOIN Member ON BMT.Member_ID = Member.Member_ID
WHERE BMT.Book_State_ID IN (1, 2) --where 1 means 'NEW' and 2 'Like New'
group by Member.Member_FirstName, Member.Member_LastName
order by Responsible_readers DESC;
--DROP VIEW Responsib_lereaders;
select * from Responsible_readers

CREATE view Most_Barrowed_Books as
select TOP 2
Book.Book_name, COUNT(*) as Barrow
from Book_Member_Transaction BMT
join Book on BMT.Book_Copies_ID = Book.Book_ID
group by Book.Book_name
order by Barrow DESC;
--DROP VIEW Most_Barrowed_Books;
select * from Most_Barrowed_Books

CREATE view lastmemberadded as 
select top 1
M.Member_ID, M.Member_FirstName, M.Member_LastName
from Member M
ORDER BY M.Member_ID DESC;

SELECT * FROM lastmemberadded;

CREATE VIEW BookFromVendor AS
SELECT
BC.Book_Copies_ID,
B.Book_name
FROM Book_Copies BC
JOIN Book B ON BC.Book_ID = B.Book_ID
WHERE BC.Book_Vendor_ID = 3;

SELECT * FROM BookFromVendor;




--DROP PROCEDURE AddNewMember;
--Creating the prosedures
CREATE PROCEDURE AddNewMember
@Member_ID int,
@Member_FirstName varchar(100),
@Member_LastName varchar(100),
@Member_Email varchar(100),
@Member_Phone int,
@Member_Gender varchar(1),
@Street_Name varchar(100),
@City_ID int,
@Districts_ID int
AS
INSERT INTO Member (Member_ID, Member_FirstName, Member_LastName, Member_Email, Member_Phone, Member_Gender, Street_Name, City_ID, Districts_ID) 
VALUES (@Member_ID, @Member_FirstName, @Member_LastName, @Member_Email, @Member_Phone, @Member_Gender, @Street_Name, @City_ID, @Districts_ID);


EXEC AddNewMember
    @Member_ID = 5,
    @Member_FirstName = 'Rahaf',
    @Member_LastName = 'Malek',
    @Member_Email = 'rahaf.Malek@example.com',
    @Member_Phone = 0798600265,
    @Member_Gender = 'F',
    @Street_Name = '123 Othman Street',
    @City_ID = 1,
    @Districts_ID = 2;
SELECT * FROM Member;
CREATE PROCEDURE CheckBookAvailable
@Book_ID int
AS SELECT case WHEN COUNT (*) > 0 THEN 'Available' ELSE 'Not Available' end AS Availability
from Book_Copies WHERE Book_ID = @Book_ID
EXEC CheckBookAvailable @Book_ID = 9;--WILL GIVE NOT AVAILABLE CUASE ITS REALY NOT AVAILABLE

--DROP PROCEDURE UPDATETHEAUTHARINFORMATION;


--DROP procedure DeleteWrongeTransaction;
CREATE procedure DeleteWrongeTransaction 
@Book_Member_Transaction_ID int
as delete from Book_Member_Transaction  
where Book_Member_Transaction_ID = @Book_Member_Transaction_ID

select * from Book_Member_Transaction ;
exec DeleteWrongeTransaction @Book_Member_Transaction_ID = 6;
SELECT * FROM Book_Member_Transaction;

DROP procedure EditTransactionType;
CREATE PROCEDURE EditTransactionType
@Book_Member_Transaction_ID int AS
update Book_Member_Transaction set Transaction_Type = 'B' 
WHERE Book_Member_Transaction_ID = @Book_Member_Transaction_ID;
select * from Book_Member_Transaction where Book_Member_Transaction_ID = @Book_Member_Transaction_ID and Transaction_Type = 'B';
exec EditTransactionType @Book_Member_Transaction_ID = 2;
INSERT INTO Cities (City_ID, City_name) VALUES
(1, 'Amman'),
(2, 'Zarqa'),
(3, 'Irbid');

INSERT INTO Cities (City_ID, City_name) VALUES
(NULL, 'Karak');

INSERT INTO Districts (Districts_ID, Districts_name, City_ID) VALUES
(1, 'Birayn', 2),
(2, 'Tla al-Ali', 1),
(3, 'Al Manara', 3),
(4, 'Al Quwaysimah', 1);

INSERT INTO Publisher (Publisher_ID, Publisher_Name) VALUES
(1, 'Dar Al Ketab'),
(2, 'Dar Al Fiker'),
(3, 'Dar Al-Manhal')

INSERT INTO Author (Author_ID, Author_FirstName, Author_LastName, Author_BirthDate, Author_Email, Author_Phone) VALUES
(1, 'Sara', 'Jamal', '1988-11-12', 'SaraJamal@gmail.com', 0780909090),
(2, 'Fadi', 'Zaghmout', '1978-12-22', 'Fadi1222@gmail.com', 0780908890),
(3, 'Conan', 'Doyle', '1985-07-30', 'ConanHolmese@gmail.com', 0780932190);

INSERT INTO Book (Book_ID, Book_name, Book_genre, ISBN) VALUES
(1, 'Pillars of Salt', 'Romance, Mystery', '2234587693876'),
(2, 'Circe', 'Fantasy', '2234584321876'),
(3, 'The Adventures of Sherlock Holmes', 'Mystery', '2238754213876'),
(4, 'House of Flame and Shadow', 'Romance', '2231117693876');
DELETE From Book where Book_ID = 2;
SELECT * FROM Book_Details WHERE Book_ID = 2;
INSERT INTO Member (Member_ID, Member_FirstName, Member_LastName, Member_Email, Member_Phone, Member_Gender, Street_Name, City_ID, Districts_ID) VALUES
(1, 'Raneem', 'Mohammed', 'raneemyahya@gmail.com', 0784537658, 'F', '453 Zaki Muhammad Sayed ST', 1, 4),
(2, 'Zakaria', 'Sami', 'samizakaria@gmail.com', 0788767658, 'M', '655 Mufleh Al Hemlan ST', 3, 3),
(3, 'Hala', 'Khaled', 'khaled1265@gmail.com', 0784533456, 'F', '321 Muhammad Sami ST', 1, 2);

INSERT INTO Book_Vendor (Book_Vendor_ID, Book_Vendor_contact_Name, Book_Vendor_Email, Book_Vendor_Phone, Street_Name, City_ID, Dist_ID) VALUES
(1, 'Irbid Book Center', 'irbidcenter@email.com', 0985463241, '441 Muhammad ST', 2, 1),
(2, 'Borien Book Centre', 'BBcenter@email.com', 0985786941, '4876 Yajouz ST', 3, 3),
(3, 'Jordan Books', 'Jordanbooks@email.com', 0985564741, '551 Sami ST', 1, 4);

INSERT INTO Book_Details (Book_ID, Publisher_ID, Author_ID) VALUES
(3, 2, 3),
(1, 3, 3),
(2, 1, 2),
(2, 1, 1);

INSERT INTO Book_Details (Book_ID, Publisher_ID, Author_ID) VALUES
(NULL, null, null);
select * from Book_Details;
INSERT INTO Book_State (Book_State_ID, Book_State_decs) VALUES
(1, 'NEW'),
(2, 'LIKE NEW'),
(3, 'GOOD'),
(4, 'FAIR'),
(5, 'POOR'),
(6, 'DAMAGED'),
(7, 'UNUSABLE');

INSERT INTO Book_Copies (Book_Copies_ID, Book_ID, Book_Vendor_ID, Received_State) VALUES
(1, 1, 2, 2),
(2, 3, 1, 4),
(3, 2, 3, 1),
(4, 4, 3, 1),
(5, 3, 3, 1);

INSERT INTO Book_Member_Transaction (Book_Member_Transaction_ID, Transaction_Type, Transaction_Date, Book_Copies_ID, Member_ID, Book_State_ID) VALUES
(1, 'B', '2023-12-03', 1, 1, 3),
(2, 'R', '2023-11-24', 2, 1, 3),
(3, 'B', '2024-01-20', 3, 3, 1),
(4, 'R', '2023-12-18', 1, 2, 1),
(5, 'R', '2023-02-10', 1, 3, 7);
INSERT INTO Book_Member_Transaction (Book_Member_Transaction_ID, Transaction_Type, Transaction_Date, Book_Copies_ID, Member_ID, Book_State_ID) VALUES
(7, 'B', NULL, 3, 2, 1);
INSERT INTO Book_Member_Transaction (Book_Member_Transaction_ID, Transaction_Type, Transaction_Date, Book_Copies_ID, Member_ID, Book_State_ID) VALUES
(11, 'R', '2023-10-07', 3, 2, 7);


--drop login Librarian;
--drop user Librarian;
create login Librarian with password = '12341234'
create user Librarian for login Librarian
GRANT INSERT, UPDATE, SELECT ON Book_Member_Transaction TO Librarian;
GRANT INSERT, UPDATE, SELECT ON Member TO Librarian;


create login Users with password = '56785678'
create user Users for login Users
GRANT SELECT ON Book_Member_Transaction TO Librarian;
GRANT SELECT ON Book_Copies TO Librarian;

create login Assistantlibrarian with password = '1234'
create user Assistantlibrarian for login Assistantlibrarian
GRANT INSERT, UPDATE, SELECT ON Book_Member_Transaction TO Assistantlibrarian;
GRANT INSERT, UPDATE, SELECT ON Book_Copies TO Assistantlibrarian;
GRANT INSERT, UPDATE, SELECT ON Member TO Assistantlibrarian;

--drop login Librarymanager;
--drop user Librarymanager;
create login Librarymanager with password = '12345678'
create user Librarymanager for login Librarymanager
GRANT INSERT, UPDATE, DELETE, SELECT ON Book_Member_Transaction TO Librarymanager;
GRANT INSERT, UPDATE, DELETE, SELECT ON Book_Copies TO Librarymanager;
GRANT INSERT, UPDATE, DELETE, SELECT ON Member TO Librarymanager;
GRANT INSERT, UPDATE, DELETE, SELECT ON Book_Details TO Librarymanager;
Select * from INFORMATION_SCHEMA.TABLE_PRIVILEGES where GRANTEE = 'Publicrelationsspecialists';

create login Publicrelationsspecialists with password = '87654321'
create user Publicrelationsspecialists for login Publicrelationsspecialists
GRANT INSERT, UPDATE, DELETE, SELECT ON Book_Vendor TO Publicrelationsspecialists;
GRANT INSERT, UPDATE, DELETE, SELECT ON Publisher TO Publicrelationsspecialists;
GRANT INSERT, UPDATE, DELETE, SELECT ON Book_Copies TO Publicrelationsspecialists;

SELECT * FROM Book_Vendor;

select Member_FirstName from Member where Member_ID = '1';
DELETE From Book_Member_Transaction where Book_State_ID = 7;
UPDATE Book_Vendor SET Book_Vendor_contact_Name = 'Irbid AL Keetab centre' WHERE Book_Vendor_ID = 1;
INSERT INTO Publisher (Publisher_ID, Publisher_Name) VALUES
(8, 'Dar Al NASHEER')
SELECT * FROM Publisher;
DELETE From Publisher where Publisher_ID = 8;

select Member_FirstName, Member_LastName from Member where Member_ID = 1 
group by Member_FirstName, Member_LastName;

---اشياء لرنيم to test
DELETE FROM Book_Member_Transaction where Book_Member_Transaction_ID = 7;
DELETE FROM Book_Member_Transaction where Book_Member_Transaction_ID = 8;
DELETE FROM Book_Member_Transaction where Book_Member_Transaction_ID = 9;
SELECT * FROM Responsible_readers;
SELECT * FROM Most_Barrowed_Books;
SELECT * FROM LateReturn;
SELECT * FROM Member WHERE Member_ID = 4; --KHALED
SELECT * FROM Book;
SELECT * FROM Book_Copies;
SELECT * FROM Book_Details;
SELECT * FROM Book_Member_Transaction;
SELECT * FROM Book_State;
SELECT * FROM Book_Vendor;
SELECT * FROM Member;
SELECT * FROM Publisher;
SELECT * FROM Author;
SELECT * FROM Cities;
SELECT * FROM Districts;
DROP TABLE Book_Copies;
DROP TABLE Book;
DROP TABLE Book_Member_Transaction;
DROP TABLE Book_State;
DROP TABLE Book_Details;
DROP TABLE Book_Vendor;
DROP TABLE Member;
DROP TABLE Author;
DROP TABLE Cities;
DROP TABLE Districts;
DROP TABLE Publisher;




select Member_FirstName from Member where Member_ID = '1';



DELETE From Book_Member_Transaction where Book_State_ID = 7;



UPDATE Book_Vendor SET Book_Vendor_contact_Name = 'Irbid AL Keetab centre' WHERE Book_Vendor_ID = 1;



INSERT INTO Publisher (Publisher_ID, Publisher_Name) VALUES
(10, 'Dar Al Ehsan')

Select * from Publisher;

SELECT * FROM Publisher;
DELETE From Publisher where Publisher_ID = 8;

select Member_FirstName, Member_LastName from Member where Member_ID = 1 
group by Member_FirstName, Member_LastName;