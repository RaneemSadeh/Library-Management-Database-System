# Library Management Database System

This repository contains the full documentation and implementation of a relational database system for managing library operations. It uses MySQL for backend management and PHP for the frontend interface. The system supports administrators, librarians, and library members, offering role-based access and streamlined data handling.

---

## 📚 System Overview

The project manages:

- Book inventory
- Member records
- Loan transactions
- Author and publisher relationships

It includes:

- A normalized relational schema
- SQL views and stored procedures
- A secure RBAC model
- A PHP-based user interface
- Backup and recovery mechanisms

---

## 🗂️ 1. Physical Database Schema

A normalized schema was built using MySQL, designed for data integrity and minimal redundancy.

### Core Tables

- **Books**: Title, ISBN, year
- **Authors**: Author details linked to books
- **Members**: User data (name, contact)
- **Loans**: Book lending records
- **Publishers**: Book publishers
- **book_authors**: M:N relationship table between books and authors

Primary and foreign key constraints ensure referential integrity.

---

## ⚙️ 2. Key Features & Functionality

### SQL Views

- `AvailableBooks`: Lists books currently not on loan
- `OverdueLoans`: Lists books with past-due return dates
- `MemberLoanHistory`: Shows all loans by a given member
- `AuthorBookList`: Displays all books by a particular author

### Stored Procedures

- `AddNewMember`: Adds a new member
- `CheckoutBook`: Processes a loan
- `ReturnBook`: Updates loan return status
- `SearchBooksByTitle`: Title-based search

These stored procedures enhance reuse and enforce validation.

---

## 🔐 3. Security Model: Roles & Privileges

Implements role-based access control (RBAC) to limit user actions.

| Username (Role) | Privileges | Description |
|-----------------|------------|-------------|
| `admin`         | ALL        | Full control over schema and data |
| `librarian`     | SELECT, INSERT, UPDATE on Loans, Members | Handles daily library functions |
| `member_user`   | SELECT on Views | Read-only access to available books and loan history |

---

## 🖥️ 4. User Interface (PHP)

A web-based frontend built using PHP enables easy interaction with the database, especially for librarians.

### Key UI Pages

- **Homepage**: Navigation hub
- **Book Management**: Add/edit book records
- **Member Management**: Manage user accounts
- **Loan Processing**: Check books in and out
- **Search Page**: Search the catalog using a form

The UI supports all core librarian operations through secure, validated form inputs.

---

## 🛡️ 5. Database Maintenance & Testing

### Backup & Recovery

- **Export**: Regular full database exports (`.sql` format)
- **Import**: Restores the database in case of failure using the latest backup

### Testing Strategy

- **Data Validation**: Primary/foreign key checks, cascading rules
- **Output Validation**: Manual result comparison of queries, views, and stored procedures
- **Security Validation**: Attempted access control breaches with each user role
- **GUI Validation**: Verified frontend operations reflected accurate changes in the database
