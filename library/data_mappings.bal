// Data storage and ID generation utilities for the library management system.
// This module provides in-memory storage tables and functions to generate unique identifiers.

import ballerina/time;

// In-memory storage table for books with thread-safe isolated access
isolated map<Book> booksTable = {};

// In-memory storage table for members with thread-safe isolated access
isolated map<Member> membersTable = {};

// In-memory storage table for borrow records with thread-safe isolated access
isolated map<BorrowRecord> borrowRecordsTable = {};

// Counter for generating unique book ISBNs (starts at 1000)
isolated int bookCounter = 1000;

// Counter for generating unique member IDs (starts at 2000)
isolated int memberCounter = 2000;

// Counter for generating unique borrow record IDs (starts at 3000)
isolated int borrowCounter = 3000;

// Generates a unique ISBN for a new book
//
// + return - Unique ISBN in format "ISBN-{number}"
isolated function generateIsbn() returns string {
    lock {
        bookCounter += 1;
        return string `ISBN-${bookCounter}`;
    }
}

// Generates a unique member ID for a new member
//
// + return - Unique member ID in format "MEM-{number}"
isolated function generateMemberId() returns string {
    lock {
        memberCounter += 1;
        return string `MEM-${memberCounter}`;
    }
}

// Generates a unique borrow record ID for a new transaction
//
// + return - Unique borrow ID in format "BRW-{number}"
isolated function generateBorrowId() returns string {
    lock {
        borrowCounter += 1;
        return string `BRW-${borrowCounter}`;
    }
}

// Gets the current date and time as an ISO 8601 formatted string
//
// + return - Current UTC date-time as string
isolated function getCurrentDate() returns string {
    time:Utc currentUtc = time:utcNow();
    string dateString = time:utcToString(currentUtc);
    return dateString;
}
