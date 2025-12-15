# Dart REST API - Todo Application

A RESTful API server built with Dart and Shelf framework for managing todo items with SQLite database.

## Features

- Full CRUD operations for todo items
- SQLite database integration
- Clean architecture with separation of concerns (Handler → Service → Repository)
- Dependency Injection pattern
- Input validation and error handling
- JSON request/response format
- Request logging middleware

## Tech Stack

- **Language**: Dart 3.10.3+
- **HTTP Framework**: Shelf 1.4.2
- **Router**: Shelf Router 1.1.4
- **Database**: SQLite3 3.1.1
- **HTTP Client**: http 1.6.0

## Project Structure

```
lib/
├── config/         # Database configuration
├── constants/      # Application constants and enums
├── di/            # Dependency injection setup
├── dto/           # Data Transfer Objects for requests
├── handler/       # HTTP request handlers
├── model/         # Domain models
├── repository/    # Database layer
├── router/        # Route definitions
├── service/       # Business logic layer
└── tools/         # Utilities and custom exceptions

bin/
└── server.dart    # Application entry point
```

## Installation

1. Ensure you have Dart SDK 3.10.3 or higher installed:
```bash
dart --version
```

2. Clone the repository:
```bash
git clone <repository-url>
cd rest-api
```

3. Install dependencies:
```bash
dart pub get
```

## Running the Server

Start the server:
```bash
dart run bin/server.dart
```

The server will start on `http://0.0.0.0:8080`

## API Endpoints

### Create Todo
```http
POST /todo
Content-Type: application/json

{
  "title": "Buy groceries",
  "status": 0
}
```

**Response (200)**:
```json
{
  "result": {
    "id": 1,
    "title": "Buy groceries",
    "status": 0
  }
}
```

### Get All Todos
```http
GET /todo
```

**Response (200)**:
```json
{
  "result": [
    {
      "id": 1,
      "title": "Buy groceries",
      "status": 0
    },
    {
      "id": 2,
      "title": "Complete project",
      "status": 1
    }
  ]
}
```

### Get Todo by ID
```http
GET /todo/{id}
```

**Response (200)**:
```json
{
  "result": {
    "id": 1,
    "title": "Buy groceries",
    "status": 0
  }
}
```

**Response (404)**:
```json
{
  "error": "Todo with id 999 not found",
  "result": null
}
```

### Update Todo
```http
PUT /todo/{id}
Content-Type: application/json

{
  "title": "Buy groceries and cook dinner",
  "status": 1
}
```

**Response (200)**:
```json
{
  "result": {
    "id": 1,
    "title": "Buy groceries and cook dinner",
    "status": 1
  }
}
```

### Delete Todo
```http
DELETE /todo/{id}
```

**Response (200)**:
```json
{
  "message": "Todo deleted successfully",
  "result": null
}
```

## Todo Status Values

- `0` - Incomplete
- `1` - Complete

## Validation Rules

- **Title**:
  - Cannot be empty
  - Maximum length: 200 characters

## Error Responses

All errors follow this format:

```json
{
  "error": "Error message description",
  "result": null
}
```

**HTTP Status Codes**:
- `200` - Success
- `400` - Bad Request (validation errors, invalid ID format)
- `404` - Not Found
- `500` - Internal Server Error

## Database

The application uses SQLite database stored in `db.sqlite` file.

**Todo Table Schema**:
```sql
CREATE TABLE todos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  status INTEGER NOT NULL
);
```

## Development

### Run Tests
```bash
dart test
```

### Code Analysis
```bash
dart analyze
```

## Architecture

The application follows clean architecture principles:

1. **Handler Layer** (`lib/handler/`): Handles HTTP requests/responses
2. **Service Layer** (`lib/service/`): Contains business logic
3. **Repository Layer** (`lib/repository/`): Database operations
4. **Model Layer** (`lib/model/`): Domain models
5. **DTO Layer** (`lib/dto/`): Data transfer objects with validation

### Dependency Flow
```
Request → Handler → Service → Repository → Database
         ↓         ↓          ↓
        DTO → Validation → Model
```

## Example Usage with cURL

```bash
# Create a new todo
curl -X POST http://localhost:8080/todo \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Dart", "status": 0}'

# Get all todos
curl http://localhost:8080/todo

# Get specific todo
curl http://localhost:8080/todo/1

# Update todo
curl -X PUT http://localhost:8080/todo/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Dart and Flutter", "status": 1}'

# Delete todo
curl -X DELETE http://localhost:8080/todo/1
```

## License

This project is for learning purposes.

## Contributing

This is a learning project. Feel free to fork and experiment!
