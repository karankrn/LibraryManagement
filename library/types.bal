// Represents a book in the library system
//
// + isbn - Unique identifier for the book (auto-generated)
// + title - Title of the book
// + author - Author of the book
// + genre - Genre/category of the book
// + totalCopies - Total number of copies owned by the library
// + availableCopies - Number of copies currently available for borrowing
public type Book record {|
    string isbn;
    string title;
    string author;
    string genre;
    int totalCopies;
    int availableCopies;
|};

// Represents a library member
//
// + memberId - Unique identifier for the member (auto-generated)
// + name - Full name of the member
// + email - Email address of the member
// + phone - Phone number of the member
public type Member record {|
    string memberId;
    string name;
    string email;
    string phone;
|};

// Represents a book borrowing transaction
//
// + borrowId - Unique identifier for the borrow transaction (auto-generated)
// + memberId - ID of the member who borrowed the book
// + isbn - ISBN of the borrowed book
// + borrowDate - Date when the book was borrowed (ISO 8601 format)
// + returnDate - Date when the book was returned, null if not yet returned
public type BorrowRecord record {|
    string borrowId;
    string memberId;
    string isbn;
    string borrowDate;
    string? returnDate;
|};

// Request payload for adding or updating a book
//
// + title - Title of the book
// + author - Author of the book
// + genre - Genre/category of the book
// + totalCopies - Total number of copies
public type BookRequest record {|
    string title;
    string author;
    string genre;
    int totalCopies;
|};

// Request payload for registering or updating a member
//
// + name - Full name of the member
// + email - Email address of the member
// + phone - Phone number of the member
public type MemberRequest record {|
    string name;
    string email;
    string phone;
|};

// Request payload for borrowing a book
//
// + memberId - ID of the member borrowing the book
// + isbn - ISBN of the book to borrow
public type BorrowRequest record {|
    string memberId;
    string isbn;
|};

// Standard error response
//
// + message - Error message describing what went wrong
// + success - Always false for error responses
public type ErrorResponse record {|
    string message;
    boolean success = false;
|};

// Standard success response
//
// + message - Success message
// + success - Always true for success responses
public type SuccessResponse record {|
    string message;
    boolean success = true;
|};
