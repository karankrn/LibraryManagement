// Book management functions

// Adds a new book to the library system
//
// + bookRequest - Book details to add
// + return - The newly created book with auto-generated ISBN
isolated function addBook(BookRequest bookRequest) returns Book {
    string isbn = generateIsbn();
    Book newBook = {
        isbn: isbn,
        title: bookRequest.title,
        author: bookRequest.author,
        genre: bookRequest.genre,
        totalCopies: bookRequest.totalCopies,
        availableCopies: bookRequest.totalCopies
    };
    lock {
        booksTable[isbn] = newBook.cloneReadOnly();
    }
    return newBook;
}

// Retrieves a book by its ISBN
//
// + isbn - ISBN of the book to retrieve
// + return - The book if found, null otherwise
isolated function getBook(string isbn) returns Book? {
    lock {
        Book? book = booksTable[isbn];
        if book is Book {
            return book.clone();
        }
        return ();
    }
}

// Retrieves all books in the library
//
// + return - Array of all books
isolated function getAllBooks() returns Book[] {
    lock {
        return booksTable.toArray().clone();
    }
}

// Updates an existing book's details
// Note: Available copies are adjusted based on the change in total copies
//
// + isbn - ISBN of the book to update
// + bookRequest - Updated book details
// + return - The updated book if found, null otherwise
isolated function updateBook(string isbn, BookRequest bookRequest) returns Book? {
    Book? existingBook = ();
    lock {
        Book? tempBook = booksTable[isbn];
        if tempBook is Book {
            existingBook = tempBook.clone();
        }
    }
    
    if existingBook is () {
        return ();
    }
    
    Book currentBook = existingBook;
    int copiesDifference = bookRequest.totalCopies - currentBook.totalCopies;
    int newAvailableCopies = currentBook.availableCopies + copiesDifference;
    
    Book updatedBook = {
        isbn: isbn,
        title: bookRequest.title,
        author: bookRequest.author,
        genre: bookRequest.genre,
        totalCopies: bookRequest.totalCopies,
        availableCopies: newAvailableCopies
    };
    
    lock {
        booksTable[isbn] = updatedBook.cloneReadOnly();
    }
    return updatedBook;
}

// Deletes a book from the library system
//
// + isbn - ISBN of the book to delete
// + return - True if book was deleted, false if not found
isolated function deleteBook(string isbn) returns boolean {
    lock {
        Book? removedBook = booksTable.removeIfHasKey(isbn);
        return removedBook is Book;
    }
}

// Member management functions

// Registers a new member in the library system
//
// + memberRequest - Member details to register
// + return - The newly created member with auto-generated member ID
isolated function addMember(MemberRequest memberRequest) returns Member {
    string memberId = generateMemberId();
    Member newMember = {
        memberId: memberId,
        name: memberRequest.name,
        email: memberRequest.email,
        phone: memberRequest.phone
    };
    lock {
        membersTable[memberId] = newMember.cloneReadOnly();
    }
    return newMember;
}

// Retrieves a member by their ID
//
// + memberId - ID of the member to retrieve
// + return - The member if found, null otherwise
isolated function getMember(string memberId) returns Member? {
    lock {
        Member? member = membersTable[memberId];
        if member is Member {
            return member.clone();
        }
        return ();
    }
}

// Retrieves all registered members
//
// + return - Array of all members
isolated function getAllMembers() returns Member[] {
    lock {
        return membersTable.toArray().clone();
    }
}

// Updates an existing member's details
//
// + memberId - ID of the member to update
// + memberRequest - Updated member details
// + return - The updated member if found, null otherwise
isolated function updateMember(string memberId, MemberRequest memberRequest) returns Member? {
    Member? existingMember = ();
    lock {
        Member? tempMember = membersTable[memberId];
        if tempMember is Member {
            existingMember = tempMember.clone();
        }
    }
    
    if existingMember is () {
        return ();
    }
    
    Member updatedMember = {
        memberId: memberId,
        name: memberRequest.name,
        email: memberRequest.email,
        phone: memberRequest.phone
    };
    
    lock {
        membersTable[memberId] = updatedMember.cloneReadOnly();
    }
    return updatedMember;
}

// Deletes a member from the library system
//
// + memberId - ID of the member to delete
// + return - True if member was deleted, false if not found
isolated function deleteMember(string memberId) returns boolean {
    lock {
        Member? removedMember = membersTable.removeIfHasKey(memberId);
        return removedMember is Member;
    }
}

// Borrowing management functions

// Processes a book borrowing request
// Validates member and book existence, checks availability, and updates inventory
//
// + borrowRequest - Borrowing request details
// + return - The created borrow record, or an error if validation fails
isolated function borrowBook(BorrowRequest borrowRequest) returns BorrowRecord|error {
    string borrowId = generateBorrowId();
    string currentDate = getCurrentDate();
    
    // Check if member exists
    boolean memberExists = false;
    lock {
        memberExists = membersTable.hasKey(borrowRequest.memberId);
    }
    if !memberExists {
        return error("Member not found");
    }
    
    // Check if book exists
    Book? book = ();
    lock {
        Book? tempBook = booksTable[borrowRequest.isbn];
        if tempBook is Book {
            book = tempBook.clone();
        }
    }
    if book is () {
        return error("Book not found");
    }
    
    Book currentBook = book;
    
    // Check if book is available
    if currentBook.availableCopies <= 0 {
        return error("Book not available");
    }
    
    // Create borrow record
    BorrowRecord newBorrowRecord = {
        borrowId: borrowId,
        memberId: borrowRequest.memberId,
        isbn: borrowRequest.isbn,
        borrowDate: currentDate,
        returnDate: ()
    };
    
    lock {
        borrowRecordsTable[borrowId] = newBorrowRecord.cloneReadOnly();
    }
    
    // Update book availability
    Book updatedBook = {
        isbn: currentBook.isbn,
        title: currentBook.title,
        author: currentBook.author,
        genre: currentBook.genre,
        totalCopies: currentBook.totalCopies,
        availableCopies: currentBook.availableCopies - 1
    };
    
    lock {
        booksTable[borrowRequest.isbn] = updatedBook.cloneReadOnly();
    }
    
    return newBorrowRecord;
}

// Processes a book return
// Updates the borrow record with return date and increments available copies
//
// + borrowId - ID of the borrow record
// + return - The updated borrow record, or an error if validation fails
isolated function returnBook(string borrowId) returns BorrowRecord|error {
    string currentDate = getCurrentDate();
    
    // Check if borrow record exists
    BorrowRecord? borrowRecord = ();
    lock {
        BorrowRecord? tempRecord = borrowRecordsTable[borrowId];
        if tempRecord is BorrowRecord {
            borrowRecord = tempRecord.clone();
        }
    }
    if borrowRecord is () {
        return error("Borrow record not found");
    }
    
    BorrowRecord currentBorrowRecord = borrowRecord;
    
    // Check if already returned
    string? returnDate = currentBorrowRecord.returnDate;
    if returnDate is string {
        return error("Book already returned");
    }
    
    // Update borrow record
    BorrowRecord updatedBorrowRecord = {
        borrowId: currentBorrowRecord.borrowId,
        memberId: currentBorrowRecord.memberId,
        isbn: currentBorrowRecord.isbn,
        borrowDate: currentBorrowRecord.borrowDate,
        returnDate: currentDate
    };
    
    lock {
        borrowRecordsTable[borrowId] = updatedBorrowRecord.cloneReadOnly();
    }
    
    // Update book availability
    Book? book = ();
    lock {
        Book? tempBook = booksTable[currentBorrowRecord.isbn];
        if tempBook is Book {
            book = tempBook.clone();
        }
    }
    
    if book is Book {
        Book currentBook = book;
        Book updatedBook = {
            isbn: currentBook.isbn,
            title: currentBook.title,
            author: currentBook.author,
            genre: currentBook.genre,
            totalCopies: currentBook.totalCopies,
            availableCopies: currentBook.availableCopies + 1
        };
        lock {
            booksTable[currentBorrowRecord.isbn] = updatedBook.cloneReadOnly();
        }
    }
    
    return updatedBorrowRecord;
}

// Retrieves all borrow records in the system
//
// + return - Array of all borrow records
isolated function getAllBorrowRecords() returns BorrowRecord[] {
    lock {
        return borrowRecordsTable.toArray().clone();
    }
}

// Retrieves all borrow records for a specific member
//
// + memberId - ID of the member
// + return - Array of borrow records for the specified member
isolated function getBorrowRecordsByMember(string memberId) returns BorrowRecord[] {
    lock {
        BorrowRecord[] allRecords = borrowRecordsTable.toArray();
        BorrowRecord[] memberRecords = from BorrowRecord borrowRecord in allRecords
                                        where borrowRecord.memberId == memberId
                                        select borrowRecord;
        return memberRecords.clone();
    }
}
