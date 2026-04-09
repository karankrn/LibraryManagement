import ballerina/http;

listener http:Listener httpListener = check new (serverPort);

service / on httpListener {
    resource function get .() returns json {
        return {
            message: "Library Management System API",
            version: "1.0.0",
            endpoints: {
                books: {
                    "POST /library/books": "Add a new book",
                    "GET /library/books": "Get all books",
                    "GET /library/books/{isbn}": "Get a book by ISBN",
                    "PUT /library/books/{isbn}": "Update a book",
                    "DELETE /library/books/{isbn}": "Delete a book"
                },
                members: {
                    "POST /library/members": "Register a new member",
                    "GET /library/members": "Get all members",
                    "GET /library/members/{memberId}": "Get a member by ID",
                    "PUT /library/members/{memberId}": "Update a member",
                    "DELETE /library/members/{memberId}": "Delete a member"
                },
                borrowing: {
                    "POST /library/borrow": "Borrow a book",
                    "POST /library/return/{borrowId}": "Return a book",
                    "GET /library/borrow": "Get all borrow records",
                    "GET /library/borrow/member/{memberId}": "Get borrow records by member"
                }
            }
        };
    }
}

service /library on httpListener {

    // Book endpoints
    
    resource function post books(@http:Payload BookRequest bookRequest) returns Book {
        return addBook(bookRequest);
    }

    resource function get books() returns Book[] {
        return getAllBooks();
    }

    resource function get books/[string isbn]() returns Book|ErrorResponse {
        Book? book = getBook(isbn);
        if book is () {
            return {message: "Book not found"};
        }
        return book;
    }

    resource function put books/[string isbn](@http:Payload BookRequest bookRequest) returns Book|ErrorResponse {
        Book? updatedBook = updateBook(isbn, bookRequest);
        if updatedBook is () {
            return {message: "Book not found"};
        }
        return updatedBook;
    }

    resource function delete books/[string isbn]() returns http:Ok|http:NotFound {
        boolean deleted = deleteBook(isbn);
        if !deleted {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // Member endpoints
    
    resource function post members(@http:Payload MemberRequest memberRequest) returns Member {
        return addMember(memberRequest);
    }

    resource function get members() returns Member[] {
        return getAllMembers();
    }

    resource function get members/[string memberId]() returns Member|ErrorResponse {
        Member? member = getMember(memberId);
        if member is () {
            return {message: "Member not found"};
        }
        return member;
    }

    resource function put members/[string memberId](@http:Payload MemberRequest memberRequest) returns Member|ErrorResponse {
        Member? updatedMember = updateMember(memberId, memberRequest);
        if updatedMember is () {
            return {message: "Member not found"};
        }
        return updatedMember;
    }

    resource function delete members/[string memberId]() returns http:Ok|http:NotFound {
        boolean deleted = deleteMember(memberId);
        if !deleted {
            return http:NOT_FOUND;
        }
        return http:OK;
    }

    // Borrowing endpoints
    
    resource function post borrow(@http:Payload BorrowRequest borrowRequest) returns BorrowRecord|ErrorResponse {
        BorrowRecord|error borrowResult = borrowBook(borrowRequest);
        if borrowResult is error {
            return {message: borrowResult.message()};
        }
        return borrowResult;
    }

    resource function post 'return/[string borrowId]() returns BorrowRecord|ErrorResponse {
        BorrowRecord|error returnResult = returnBook(borrowId);
        if returnResult is error {
            return {message: returnResult.message()};
        }
        return returnResult;
    }

    resource function get borrow() returns BorrowRecord[] {
        return getAllBorrowRecords();
    }

    resource function get borrow/member/[string memberId]() returns BorrowRecord[] {
        return getBorrowRecordsByMember(memberId);
    }
}
