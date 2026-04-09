// Book management functions

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

isolated function getBook(string isbn) returns Book? {
    lock {
        Book? book = booksTable[isbn];
        if book is Book {
            return book.clone();
        }
        return ();
    }
}

isolated function getAllBooks() returns Book[] {
    lock {
        return booksTable.toArray().clone();
    }
}

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

isolated function deleteBook(string isbn) returns boolean {
    lock {
        Book? removedBook = booksTable.removeIfHasKey(isbn);
        return removedBook is Book;
    }
}

// Member management functions

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

isolated function getMember(string memberId) returns Member? {
    lock {
        Member? member = membersTable[memberId];
        if member is Member {
            return member.clone();
        }
        return ();
    }
}

isolated function getAllMembers() returns Member[] {
    lock {
        return membersTable.toArray().clone();
    }
}

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

isolated function deleteMember(string memberId) returns boolean {
    lock {
        Member? removedMember = membersTable.removeIfHasKey(memberId);
        return removedMember is Member;
    }
}

// Borrowing management functions

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

isolated function getAllBorrowRecords() returns BorrowRecord[] {
    lock {
        return borrowRecordsTable.toArray().clone();
    }
}

isolated function getBorrowRecordsByMember(string memberId) returns BorrowRecord[] {
    lock {
        BorrowRecord[] allRecords = borrowRecordsTable.toArray();
        BorrowRecord[] memberRecords = from BorrowRecord borrowRecord in allRecords
                                        where borrowRecord.memberId == memberId
                                        select borrowRecord;
        return memberRecords.clone();
    }
}
