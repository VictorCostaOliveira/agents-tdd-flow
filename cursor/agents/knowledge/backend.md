# Backend Development Checklist

## API Design

### RESTful API Principles
- [ ] **Resource-Based URLs**: `/api/users`, `/api/posts/:id`
- [ ] **HTTP Methods**: GET (read), POST (create), PUT/PATCH (update), DELETE (delete)
- [ ] **Proper Status Codes**: 200, 201, 204, 400, 401, 403, 404, 500, etc.
- [ ] **Consistent Naming**: Use plural nouns, kebab-case
- [ ] **Versioning**: `/api/v1/...` for backward compatibility
- [ ] **Idempotency**: PUT, DELETE should be idempotent

### API Endpoints Structure
```
GET    /api/v1/users          # List users (with pagination)
POST   /api/v1/users          # Create user
GET    /api/v1/users/:id      # Get user by ID
PUT    /api/v1/users/:id      # Update user (full)
PATCH  /api/v1/users/:id      # Update user (partial)
DELETE /api/v1/users/:id      # Delete user

GET    /api/v1/users/:id/posts  # Nested resource
```

### Request/Response Format
```json
// Request
{
  "data": {
    "name": "John Doe",
    "email": "john@example.com"
  }
}

// Success Response
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2026-02-10T10:00:00Z"
  }
}

// Error Response
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "fields": {
      "email": "Must be a valid email address"
    }
  }
}
```

### API Best Practices
- [ ] **Pagination**: Limit results, provide total count
- [ ] **Filtering**: Support query parameters (`?status=active&role=admin`)
- [ ] **Sorting**: Support `?sort=createdAt:desc`
- [ ] **Field Selection**: Allow `?fields=id,name,email`
- [ ] **Rate Limiting**: Prevent abuse
- [ ] **CORS**: Configure properly for frontend
- [ ] **API Documentation**: Use OpenAPI/Swagger

## Architecture Layers

### Layered Architecture
```
Controllers/Routes    → Handle HTTP requests/responses
  ↓
Services             → Business logic, orchestration
  ↓
Repositories/DAL     → Data access, database queries
  ↓
Models/Entities      → Data structures, validation
  ↓
Database             → Persistent storage
```

### Layer Responsibilities

#### Controllers
- Parse and validate request input
- Call appropriate service methods
- Format and return responses
- Handle HTTP-specific concerns (status codes, headers)
- Should be thin (< 20 lines per action)

#### Services
- Implement business logic
- Orchestrate multiple repositories/external APIs
- Handle transactions
- Throw domain-specific errors
- Should be testable without HTTP context

#### Repositories
- Encapsulate data access
- Abstract database operations
- Return domain models, not raw DB records
- Handle query optimization
- One repository per entity/aggregate

#### Models
- Define data structure and types
- Implement validation rules
- Define relationships
- Business logic specific to entity

## Authentication & Authorization

### Authentication Strategies
- **JWT**: Stateless, good for APIs
- **Session**: Stateful, good for web apps
- **OAuth 2.0**: Third-party authentication
- **API Keys**: For service-to-service

### Authentication Flow
```
1. User sends credentials
2. Server validates credentials
3. Server generates token (JWT) or session
4. Client stores token (httpOnly cookie or localStorage)
5. Client sends token with each request
6. Server validates token and identifies user
```

### Authorization Patterns
- **RBAC (Role-Based)**: User → Roles → Permissions
- **ABAC (Attribute-Based)**: Based on user/resource attributes
- **ACL (Access Control List)**: Per-resource permissions

### Security Checklist
- [ ] **Password Hashing**: Use bcrypt, argon2 (NEVER plain text)
- [ ] **Token Security**: HttpOnly cookies for web, secure storage
- [ ] **Refresh Tokens**: Short-lived access tokens + refresh tokens
- [ ] **Rate Limiting**: Prevent brute force attacks
- [ ] **Input Sanitization**: Prevent injection attacks
- [ ] **CORS**: Whitelist allowed origins
- [ ] **CSRF Protection**: Use tokens for state-changing operations
- [ ] **Secrets Management**: Use environment variables, never commit

## Data Validation

### Input Validation
- [ ] **Type Checking**: Ensure correct data types
- [ ] **Required Fields**: Validate presence
- [ ] **Format Validation**: Email, URL, phone, etc.
- [ ] **Range Validation**: Min/max length, value ranges
- [ ] **Business Rules**: Custom validation logic
- [ ] **Sanitization**: Remove/escape dangerous characters

### Validation Layers
1. **Schema Validation**: Request structure (Joi, Yup, Zod)
2. **Business Validation**: Domain rules (in services)
3. **Database Constraints**: Last line of defense

### Example Validation
```javascript
// Schema validation
const userSchema = {
  name: string().required().min(2).max(100),
  email: string().required().email(),
  age: number().min(18).max(120),
  role: string().oneOf(['user', 'admin'])
}

// Business validation
if (await userExists(email)) {
  throw new ConflictError('Email already registered')
}
```

## Error Handling

### Error Types
```javascript
class ApplicationError extends Error {
  constructor(message, statusCode) {
    super(message)
    this.statusCode = statusCode
  }
}

class ValidationError extends ApplicationError {
  constructor(message, fields) {
    super(message, 400)
    this.fields = fields
  }
}

class NotFoundError extends ApplicationError {
  constructor(resource) {
    super(`${resource} not found`, 404)
  }
}

class UnauthorizedError extends ApplicationError {
  constructor() {
    super('Unauthorized', 401)
  }
}
```

### Error Handling Middleware
```javascript
app.use((err, req, res, next) => {
  // Log error
  logger.error(err)
  
  // Don't leak stack traces in production
  const isDev = process.env.NODE_ENV === 'development'
  
  res.status(err.statusCode || 500).json({
    success: false,
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: err.message,
      ...(isDev && { stack: err.stack })
    }
  })
})
```

### Error Handling Best Practices
- [ ] **Fail Fast**: Validate early, throw errors immediately
- [ ] **Specific Errors**: Use custom error classes
- [ ] **Don't Swallow**: Always handle or propagate errors
- [ ] **Log Properly**: Include context, user ID, request ID
- [ ] **User-Friendly Messages**: Don't expose internal details
- [ ] **Monitoring**: Track error rates, alert on spikes

## Database & Data Modeling

### Database Design Principles
- [ ] **Normalization**: Eliminate redundancy (3NF usually sufficient)
- [ ] **Relationships**: Define FK constraints
- [ ] **Indexes**: Add for frequently queried columns
- [ ] **Constraints**: NOT NULL, UNIQUE, CHECK constraints
- [ ] **Naming Convention**: snake_case for tables/columns
- [ ] **Timestamps**: created_at, updated_at on every table
- [ ] **Soft Deletes**: deleted_at instead of hard deletes (when needed)

### Common Relationships
```sql
-- One-to-Many: User has many Posts
users:        id, name, email
posts:        id, user_id, title, content

-- Many-to-Many: User has many Roles
users:        id, name
roles:        id, name
user_roles:   user_id, role_id

-- One-to-One: User has one Profile
users:        id, name
profiles:     id, user_id, bio, avatar
```

### Query Optimization
- [ ] **N+1 Problem**: Use joins or eager loading
- [ ] **Indexes**: Add indexes for WHERE, JOIN, ORDER BY columns
- [ ] **SELECT Specific**: Avoid SELECT *
- [ ] **Pagination**: LIMIT and OFFSET or cursor-based
- [ ] **Connection Pooling**: Reuse database connections
- [ ] **Query Analysis**: Use EXPLAIN to analyze slow queries

### Migration Best Practices
- [ ] **Version Control**: Track all schema changes
- [ ] **Reversible**: Write both up and down migrations
- [ ] **Data Safety**: Use transactions, backup before deploy
- [ ] **Incremental**: Small, focused migrations
- [ ] **Default Values**: Set for new columns on existing tables
- [ ] **Test Locally**: Run migrations on local/staging first

## Caching Strategy

### Caching Layers
```
Client (Browser Cache)
  ↓
CDN (Static Assets)
  ↓
API Gateway Cache
  ↓
Application Cache (Redis)
  ↓
Database Query Cache
  ↓
Database
```

### Caching Patterns
- **Cache-Aside**: App checks cache, then DB on miss
- **Write-Through**: Write to cache and DB simultaneously
- **Write-Behind**: Write to cache, async to DB
- **Refresh-Ahead**: Proactively refresh before expiry

### What to Cache
- [ ] **Expensive Queries**: Complex aggregations, joins
- [ ] **Frequently Accessed**: Hot data (user profiles, configs)
- [ ] **Static Data**: Reference data, rarely changes
- [ ] **Session Data**: User sessions, temporary data
- [ ] **Rate Limit Counters**: Track API usage

### Cache Invalidation
```javascript
// Time-based expiration
cache.set('user:123', userData, { ttl: 3600 }) // 1 hour

// Event-based invalidation
onUserUpdate((userId) => {
  cache.del(`user:${userId}`)
})

// Cache key patterns
const cacheKey = `users:${userId}:posts:page:${page}`
```

## Performance Optimization

### Backend Performance Checklist
- [ ] **Database Indexing**: Index frequently queried fields
- [ ] **Query Optimization**: Avoid N+1, use proper joins
- [ ] **Caching**: Cache expensive operations
- [ ] **Async Processing**: Move slow tasks to background jobs
- [ ] **Connection Pooling**: Reuse DB connections
- [ ] **Compression**: Gzip/Brotli responses
- [ ] **Pagination**: Never return unbounded results
- [ ] **Rate Limiting**: Protect against abuse
- [ ] **Load Balancing**: Distribute traffic across servers

### Async Processing
```javascript
// Example: Send email in background
app.post('/api/users', async (req, res) => {
  const user = await createUser(req.body)
  
  // Queue email, don't wait
  emailQueue.add({ userId: user.id, type: 'welcome' })
  
  res.status(201).json({ success: true, data: user })
})
```

## Testing Strategy

### Test Pyramid
```
       E2E Tests (Few)
          ↑
    Integration Tests (Some)
          ↑
    Unit Tests (Many)
```

### Unit Tests
- Test individual functions in isolation
- Mock external dependencies (DB, APIs, etc.)
- Test edge cases and error conditions
- Fast and deterministic

### Integration Tests
- Test API endpoints end-to-end
- Use test database
- Test authentication/authorization
- Test error responses

### Testing Best Practices
- [ ] **Test Behavior**: Test what, not how
- [ ] **Arrange-Act-Assert**: Structure tests clearly
- [ ] **Isolated Tests**: No dependencies between tests
- [ ] **Seed Data**: Use factories/fixtures for test data
- [ ] **Clean Up**: Reset database after each test
- [ ] **Test Coverage**: Aim for 80%+ coverage
- [ ] **CI Integration**: Run tests on every commit

## Common Backend Anti-Patterns

### ❌ Fat Controllers
Controllers with business logic, directly accessing database.

### ✅ Solution: Service Layer
Move business logic to services, controllers only handle HTTP.

### ❌ Anemic Models
Models with no behavior, just data containers.

### ✅ Solution: Rich Domain Models
Add business methods to models.

### ❌ God Service
One service doing everything.

### ✅ Solution: Single Responsibility
Break into focused services.

### ❌ Leaky Abstractions
Repository returning database-specific objects.

### ✅ Solution: Return Domain Models
Repository should return app-specific types.

## Monitoring & Logging

### Logging Best Practices
- [ ] **Structured Logging**: Use JSON format
- [ ] **Log Levels**: DEBUG, INFO, WARN, ERROR
- [ ] **Contextual Info**: Include user ID, request ID, timestamp
- [ ] **Sensitive Data**: Never log passwords, tokens, PII
- [ ] **Performance**: Log slow queries, high memory usage
- [ ] **Errors**: Log full stack trace with context

### Monitoring Metrics
- [ ] **Response Time**: P50, P95, P99 latency
- [ ] **Error Rate**: 4xx, 5xx responses
- [ ] **Throughput**: Requests per second
- [ ] **Database**: Query time, connection pool usage
- [ ] **Cache**: Hit rate, miss rate
- [ ] **System**: CPU, memory, disk usage

## Checklist Summary

Before implementing backend:
1. ✅ API endpoints designed and documented?
2. ✅ Architecture layers clearly separated?
3. ✅ Authentication/authorization strategy defined?
4. ✅ Input validation comprehensive?
5. ✅ Error handling robust?
6. ✅ Database schema designed and optimized?
7. ✅ Caching strategy in place?
8. ✅ Performance considerations addressed?
9. ✅ Testing approach defined?
10. ✅ Logging and monitoring planned?
