// Library Management System REST API
// Provides endpoints for managing books, members, and borrowing operations

import ballerina/http;

// HTTP listener for the library management API
listener http:Listener httpListener = check new (serverPort);

// Main library service providing all library management operations
service /library on httpListener {

    // Book endpoints
    
    // Adds a new book to the library
    //
    // + bookRequest - Book details
    // + return - The created book with auto-generated ISBN
    resource function post books(@http:Payload BookRequest bookRequest) returns Book {
        return addBook(bookRequest);
    }

    // Retrieves all books in the library
    //
    // + return - Array of all books
    resource function get books() returns Book[] {
        return getAllBooks();
    }

    // Retrieves a specific book by ISBN
    //
    // + isbn - ISBN of the book
    // + return - The book if found, error response otherwise
    resource function get books/[string isbn]() returns Book|ErrorResponse {
        Book? book = getBook(isbn);
        if book is () {
            return {message: "Book not found"};
        }
        return book;
    }

    // Updates an existing book
    //
    // + isbn - ISBN of the book to update
    // + bookRequest - Updated book details
    // + return - The updated book if found, error response otherwise
    resource function put books/[string isbn](@http:Payload BookRequest bookRequest) returns Book|ErrorResponse {
        Book? updatedBook = updateBook(isbn, bookRequest);
        if updatedBook is () {
            return {message: "Book not found"};
        }
        return updatedBook;
    }

    // Deletes a book from the library
    //
    // + isbn - ISBN of the book to delete
    // + return - 200 OK if deleted, 404 Not Found if book doesn't exist
    resource function delete books/[string isbn]() returns http:Ok|http:NotFound {
        boolean deleted = deleteBook(isbn);
        if !deleted {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // Member endpoints
    
    // Registers a new library member
    //
    // + memberRequest - Member details
    // + return - The created member with auto-generated member ID
    resource function post members(@http:Payload MemberRequest memberRequest) returns Member {
        return addMember(memberRequest);
    }

    // Retrieves all registered members
    //
    // + return - Array of all members
    resource function get members() returns Member[] {
        return getAllMembers();
    }

    // Retrieves a specific member by ID
    //
    // + memberId - ID of the member
    // + return - The member if found, error response otherwise
    resource function get members/[string memberId]() returns Member|ErrorResponse {
        Member? member = getMember(memberId);
        if member is () {
            return {message: "Member not found"};
        }
        return member;
    }

    // Updates an existing member
    //
    // + memberId - ID of the member to update
    // + memberRequest - Updated member details
    // + return - The updated member if found, error response otherwise
    resource function put members/[string memberId](@http:Payload MemberRequest memberRequest) returns Member|ErrorResponse {
        Member? updatedMember = updateMember(memberId, memberRequest);
        if updatedMember is () {
            return {message: "Member not found"};
        }
        return updatedMember;
    }

    // Deletes a member from the library
    //
    // + memberId - ID of the member to delete
    // + return - 200 OK if deleted, 404 Not Found if member doesn't exist
    resource function delete members/[string memberId]() returns http:Ok|http:NotFound {
        boolean deleted = deleteMember(memberId);
        if !deleted {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // Borrowing endpoints
    
    // Processes a book borrowing request
    //
    // + borrowRequest - Borrowing details (member ID and book ISBN)
    // + return - The created borrow record if successful, error response otherwise
    resource function post borrow(@http:Payload BorrowRequest borrowRequest) returns BorrowRecord|ErrorResponse {
        BorrowRecord|error borrowResult = borrowBook(borrowRequest);
        if borrowResult is error {
            return {message: borrowResult.message()};
        }
        return borrowResult;
    }

    // Processes a book return
    //
    // + borrowId - ID of the borrow record
    // + return - The updated borrow record if successful, error response otherwise
    resource function post 'return/[string borrowId]() returns BorrowRecord|ErrorResponse {
        BorrowRecord|error returnResult = returnBook(borrowId);
        if returnResult is error {
            return {message: returnResult.message()};
        }
        return returnResult;
    }

    // Retrieves all borrow records
    //
    // + return - Array of all borrow records
    resource function get borrow() returns BorrowRecord[] {
        return getAllBorrowRecords();
    }

    // Retrieves all borrow records for a specific member
    //
    // + memberId - ID of the member
    // + return - Array of borrow records for the specified member
    resource function get borrow/member/[string memberId]() returns BorrowRecord[] {
        return getBorrowRecordsByMember(memberId);
    }
}
