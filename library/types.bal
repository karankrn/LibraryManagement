// Book record type
public type Book record {|
    string isbn;
    string title;
    string author;
    string genre;
    int totalCopies;
    int availableCopies;
|};

// Member record type
public type Member record {|
    string memberId;
    string name;
    string email;
    string phone;
|};

// Borrow record type
public type BorrowRecord record {|
    string borrowId;
    string memberId;
    string isbn;
    string borrowDate;
    string? returnDate;
|};

// Request/Response types
public type BookRequest record {|
    string title;
    string author;
    string genre;
    int totalCopies;
|};

public type MemberRequest record {|
    string name;
    string email;
    string phone;
|};

public type BorrowRequest record {|
    string memberId;
    string isbn;
|};

public type ErrorResponse record {|
    string message;
    boolean success = false;
|};

public type SuccessResponse record {|
    string message;
    boolean success = true;
|};
