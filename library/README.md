# Library Management System

A RESTful API service built with Ballerina for managing library operations including books, members, and borrowing transactions.

## Features

- **Book Management**: Add, update, retrieve, and delete books
- **Member Management**: Register, update, retrieve, and delete library members
- **Borrowing System**: Process book borrowing and returns with automatic inventory tracking
- **In-Memory Storage**: Fast, thread-safe data storage with isolated access
- **Auto-Generated IDs**: Automatic generation of unique identifiers for books, members, and transactions

## Prerequisites

- Ballerina Swan Lake (2201.x.x or later)
- A text editor or IDE with Ballerina support

## Getting Started

### Running the Service

1. Clone or download this project
2. Navigate to the project directory
3. Run the service:

```bash
bal run
```

The service will start on port `9090` by default.

### Configuration

You can customize the server port by creating a `Config.toml` file:

```toml
serverPort = 8080
```

Or pass it as a command-line argument:

```bash
bal run -- -CserverPort=8080
```

## API Endpoints

### Book Endpoints

- **POST** `/library/books` - Add a new book
- **GET** `/library/books` - Get all books
- **GET** `/library/books/{isbn}` - Get a book by ISBN
- **PUT** `/library/books/{isbn}` - Update a book
- **DELETE** `/library/books/{isbn}` - Delete a book

### Member Endpoints

- **POST** `/library/members` - Register a new member
- **GET** `/library/members` - Get all members
- **GET** `/library/members/{memberId}` - Get a member by ID
- **PUT** `/library/members/{memberId}` - Update a member
- **DELETE** `/library/members/{memberId}` - Delete a member

### Borrowing Endpoints

- **POST** `/library/borrow` - Borrow a book
- **POST** `/library/return/{borrowId}` - Return a book
- **GET** `/library/borrow` - Get all borrow records
- **GET** `/library/borrow/member/{memberId}` - Get borrow records by member

## Usage Examples

### Add a Book

```bash
curl -X POST http://localhost:9090/library/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "genre": "Fiction",
    "totalCopies": 5
  }'
```

### Register a Member

```bash
curl -X POST http://localhost:9090/library/members \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890"
  }'
```

### Borrow a Book

```bash
curl -X POST http://localhost:9090/library/borrow \
  -H "Content-Type: application/json" \
  -d '{
    "memberId": "MEM-2001",
    "isbn": "ISBN-1001"
  }'
```

### Return a Book

```bash
curl -X POST http://localhost:9090/library/return/BRW-3001
```

### Get All Books

```bash
curl http://localhost:9090/library/books
```

## Data Models

### Book
```json
{
  "isbn": "ISBN-1001",
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "genre": "Fiction",
  "totalCopies": 5,
  "availableCopies": 4
}
```

### Member
```json
{
  "memberId": "MEM-2001",
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+1234567890"
}
```

### Borrow Record
```json
{
  "borrowId": "BRW-3001",
  "memberId": "MEM-2001",
  "isbn": "ISBN-1001",
  "borrowDate": "2024-01-15T10:30:00Z",
  "returnDate": null
}
```

## Project Structure

```
librarymanagement/
├── main.bal              # HTTP service and API endpoints
├── types.bal             # Data type definitions
├── functions.bal         # Business logic functions
├── data_mappings.bal     # Data storage and ID generation
├── config.bal            # Configuration variables
└── README.md             # Project documentation
```

## Error Handling

The API returns appropriate HTTP status codes and error messages:

- `200 OK` - Successful operation
- `404 Not Found` - Resource not found
- Error responses include a JSON object with `message` and `success` fields

Example error response:
```json
{
  "message": "Book not found",
  "success": false
}
```

## Features in Detail

### Thread-Safe Operations
All data operations use isolated functions with lock statements to ensure thread safety in concurrent environments.

### Automatic Inventory Management
When a book is borrowed, the available copies are automatically decremented. When returned, they are incremented back.

### Validation
- Validates member existence before allowing book borrowing
- Checks book availability before processing borrow requests
- Prevents duplicate returns of the same book

## License

This project is available for educational and commercial use.