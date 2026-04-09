import ballerina/time;

// In-memory storage with isolated access
isolated map<Book> booksTable = {};
isolated map<Member> membersTable = {};
isolated map<BorrowRecord> borrowRecordsTable = {};

isolated int bookCounter = 1000;
isolated int memberCounter = 2000;
isolated int borrowCounter = 3000;

// Generate unique ISBN
isolated function generateIsbn() returns string {
    lock {
        bookCounter += 1;
        return string `ISBN-${bookCounter}`;
    }
}

// Generate unique member ID
isolated function generateMemberId() returns string {
    lock {
        memberCounter += 1;
        return string `MEM-${memberCounter}`;
    }
}

// Generate unique borrow ID
isolated function generateBorrowId() returns string {
    lock {
        borrowCounter += 1;
        return string `BRW-${borrowCounter}`;
    }
}

// Get current date as string
isolated function getCurrentDate() returns string {
    time:Utc currentUtc = time:utcNow();
    string dateString = time:utcToString(currentUtc);
    return dateString;
}
