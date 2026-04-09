# Software Architecture Checklist

## SOLID Principles

### S - Single Responsibility Principle (SRP)
**"A class/module should have one, and only one, reason to change."**

#### Code Smells (Violations)
- Class/module doing multiple unrelated things
- Multiple reasons to modify a single component
- Mixed concerns (UI + business logic + data access)
- God classes with too many responsibilities

#### ✅ Good Example
```javascript
// ❌ Violates SRP
class UserController {
  createUser(data) {
    // Validation
    if (!data.email) throw new Error('Invalid')
    
    // Password hashing
    const hash = bcrypt.hash(data.password)
    
    // Database access
    db.users.insert({ ...data, password: hash })
    
    // Email sending
    sendEmail(data.email, 'Welcome!')
  }
}

// ✅ Follows SRP
class UserController {
  constructor(userService) {
    this.userService = userService
  }
  
  async createUser(req, res) {
    const user = await this.userService.createUser(req.body)
    res.status(201).json(user)
  }
}

class UserService {
  constructor(userRepository, emailService) {
    this.userRepository = userRepository
    this.emailService = emailService
  }
  
  async createUser(data) {
    const validatedData = this.validate(data)
    const user = await this.userRepository.create(validatedData)
    await this.emailService.sendWelcome(user.email)
    return user
  }
}
```

### O - Open/Closed Principle (OCP)
**"Open for extension, closed for modification."**

#### Code Smells
- Long if/else or switch statements for type checking
- Modifying existing code to add new features
- Hardcoded logic that requires changes for new cases

#### ✅ Good Example
```javascript
// ❌ Violates OCP
class PaymentProcessor {
  process(payment) {
    if (payment.type === 'credit_card') {
      // Credit card logic
    } else if (payment.type === 'paypal') {
      // PayPal logic
    } else if (payment.type === 'crypto') {
      // Crypto logic (requires modification!)
    }
  }
}

// ✅ Follows OCP - Strategy Pattern
class PaymentProcessor {
  constructor(strategy) {
    this.strategy = strategy
  }
  
  process(payment) {
    return this.strategy.process(payment)
  }
}

class CreditCardStrategy {
  process(payment) {
    // Credit card logic
  }
}

class PayPalStrategy {
  process(payment) {
    // PayPal logic
  }
}

// Easy to extend with new payment methods
class CryptoStrategy {
  process(payment) {
    // Crypto logic - no existing code modified!
  }
}
```

### L - Liskov Substitution Principle (LSP)
**"Subtypes must be substitutable for their base types."**

#### Code Smells
- Subclass throws exceptions on parent methods
- Subclass changes expected behavior
- Type checking before using objects
- Empty method implementations in subclasses

#### ✅ Good Example
```javascript
// ❌ Violates LSP
class Bird {
  fly() { /* flying logic */ }
}

class Penguin extends Bird {
  fly() {
    throw new Error("Penguins can't fly!") // Violates contract
  }
}

// ✅ Follows LSP
class Bird {
  move() { /* movement logic */ }
}

class FlyingBird extends Bird {
  move() { this.fly() }
  fly() { /* flying logic */ }
}

class Penguin extends Bird {
  move() { this.swim() }
  swim() { /* swimming logic */ }
}
```

### I - Interface Segregation Principle (ISP)
**"Clients shouldn't depend on interfaces they don't use."**

#### Code Smells
- Fat interfaces with many methods
- Implementing interfaces with empty/unsupported methods
- Clients forced to depend on methods they don't need

#### ✅ Good Example
```javascript
// ❌ Violates ISP
class Worker {
  work() {}
  eat() {}
  sleep() {}
}

class Robot extends Worker {
  work() { /* work */ }
  eat() { throw new Error('Robots dont eat') } // Forced to implement
  sleep() { throw new Error('Robots dont sleep') }
}

// ✅ Follows ISP
class Workable {
  work() {}
}

class Eatable {
  eat() {}
}

class Sleepable {
  sleep() {}
}

class Human extends Workable, Eatable, Sleepable {}
class Robot extends Workable {}
```

### D - Dependency Inversion Principle (DIP)
**"Depend on abstractions, not concretions."**

#### Code Smells
- High-level modules importing low-level modules directly
- Hardcoded dependencies (new ClassName() inside methods)
- Tight coupling between layers
- Difficult to test due to concrete dependencies

#### ✅ Good Example
```javascript
// ❌ Violates DIP
class UserService {
  constructor() {
    this.repository = new MySQLUserRepository() // Concrete dependency
  }
  
  getUser(id) {
    return this.repository.findById(id)
  }
}

// ✅ Follows DIP - Dependency Injection
class UserService {
  constructor(userRepository) { // Abstract dependency
    this.userRepository = userRepository
  }
  
  getUser(id) {
    return this.userRepository.findById(id)
  }
}

// Can inject different implementations
const service1 = new UserService(new MySQLUserRepository())
const service2 = new UserService(new MongoUserRepository())
const service3 = new UserService(new InMemoryUserRepository()) // For testing
```

## Design Patterns

### Creational Patterns

#### Factory Pattern
**When**: Need to create objects without specifying exact class

```javascript
class UserFactory {
  static create(type, data) {
    switch(type) {
      case 'admin': return new AdminUser(data)
      case 'guest': return new GuestUser(data)
      default: return new RegularUser(data)
    }
  }
}

const user = UserFactory.create('admin', userData)
```

#### Builder Pattern
**When**: Complex object construction with many optional parameters

```javascript
class QueryBuilder {
  constructor() {
    this.query = {}
  }
  
  select(fields) {
    this.query.fields = fields
    return this
  }
  
  where(conditions) {
    this.query.where = conditions
    return this
  }
  
  orderBy(field, direction) {
    this.query.orderBy = { field, direction }
    return this
  }
  
  build() {
    return this.query
  }
}

const query = new QueryBuilder()
  .select(['id', 'name'])
  .where({ status: 'active' })
  .orderBy('createdAt', 'desc')
  .build()
```

#### Singleton Pattern
**When**: Need exactly one instance (use sparingly, often anti-pattern)

```javascript
class Database {
  static instance = null
  
  static getInstance() {
    if (!Database.instance) {
      Database.instance = new Database()
    }
    return Database.instance
  }
}
```

### Structural Patterns

#### Repository Pattern
**When**: Abstracting data access layer

```javascript
class UserRepository {
  async findById(id) {
    return await db.users.findOne({ id })
  }
  
  async findAll(filters) {
    return await db.users.find(filters)
  }
  
  async create(userData) {
    return await db.users.insert(userData)
  }
  
  async update(id, updates) {
    return await db.users.update({ id }, updates)
  }
  
  async delete(id) {
    return await db.users.delete({ id })
  }
}
```

#### Adapter Pattern
**When**: Making incompatible interfaces work together

```javascript
// External API with different interface
class ExternalPaymentAPI {
  makePayment(cardNum, amount) {
    // External implementation
  }
}

// Adapter to match our interface
class PaymentAdapter {
  constructor() {
    this.externalAPI = new ExternalPaymentAPI()
  }
  
  processPayment(paymentData) {
    return this.externalAPI.makePayment(
      paymentData.cardNumber,
      paymentData.amount
    )
  }
}
```

#### Decorator Pattern
**When**: Adding behavior to objects dynamically

```javascript
class BaseNotification {
  send(message) {
    console.log(message)
  }
}

class EmailDecorator {
  constructor(notification) {
    this.notification = notification
  }
  
  send(message) {
    this.notification.send(message)
    this.sendEmail(message)
  }
  
  sendEmail(message) {
    // Email logic
  }
}

class SMSDecorator {
  constructor(notification) {
    this.notification = notification
  }
  
  send(message) {
    this.notification.send(message)
    this.sendSMS(message)
  }
  
  sendSMS(message) {
    // SMS logic
  }
}

// Can stack decorators
const notification = new SMSDecorator(
  new EmailDecorator(
    new BaseNotification()
  )
)
```

### Behavioral Patterns

#### Strategy Pattern
**When**: Multiple algorithms for same task, selected at runtime

```javascript
class SortStrategy {
  sort(data) {
    throw new Error('Must implement')
  }
}

class QuickSort extends SortStrategy {
  sort(data) {
    // Quick sort implementation
  }
}

class MergeSort extends SortStrategy {
  sort(data) {
    // Merge sort implementation
  }
}

class Sorter {
  constructor(strategy) {
    this.strategy = strategy
  }
  
  sort(data) {
    return this.strategy.sort(data)
  }
}
```

#### Observer Pattern
**When**: One-to-many dependency, notify multiple objects of changes

```javascript
class EventEmitter {
  constructor() {
    this.listeners = {}
  }
  
  on(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = []
    }
    this.listeners[event].push(callback)
  }
  
  emit(event, data) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(cb => cb(data))
    }
  }
}

const userEvents = new EventEmitter()
userEvents.on('userCreated', (user) => sendWelcomeEmail(user))
userEvents.on('userCreated', (user) => logUserCreation(user))
userEvents.emit('userCreated', newUser)
```

#### Command Pattern
**When**: Encapsulate requests as objects for queuing, logging, undo

```javascript
class Command {
  execute() {}
  undo() {}
}

class CreateUserCommand extends Command {
  constructor(userData, userRepository) {
    super()
    this.userData = userData
    this.userRepository = userRepository
    this.createdUser = null
  }
  
  async execute() {
    this.createdUser = await this.userRepository.create(this.userData)
    return this.createdUser
  }
  
  async undo() {
    if (this.createdUser) {
      await this.userRepository.delete(this.createdUser.id)
    }
  }
}
```

## Architecture Patterns

### Layered Architecture (N-Tier)
```
┌─────────────────────┐
│  Presentation Layer │  (Controllers, Views)
├─────────────────────┤
│   Business Layer    │  (Services, Business Logic)
├─────────────────────┤
│   Data Access Layer │  (Repositories, ORMs)
├─────────────────────┤
│      Database       │
└─────────────────────┘
```

**Pros**: Clear separation, easy to understand, good for CRUD apps
**Cons**: Can be rigid, tight coupling between layers

### Clean Architecture (Hexagonal/Onion)
```
         ┌─────────────────┐
         │   Frameworks    │  (UI, DB, External APIs)
         │   & Drivers     │
         ├─────────────────┤
         │   Interface     │  (Controllers, Gateways)
         │   Adapters      │
         ├─────────────────┤
         │   Use Cases     │  (Business Rules)
         ├─────────────────┤
         │   Entities      │  (Domain Models)
         └─────────────────┘
              (Core)
```

**Pros**: Highly testable, independent of frameworks, flexible
**Cons**: More complex, steeper learning curve

### Microservices
```
Frontend → API Gateway → [ Service A ]
                       → [ Service B ]
                       → [ Service C ]
```

**When to use**: Large teams, independent deployments, different tech stacks
**When NOT to use**: Small teams, simple apps, starting new projects

### Event-Driven Architecture
```
Service A → Event Bus → Service B
                      → Service C
                      → Service D
```

**When to use**: Async workflows, decoupled services, real-time systems
**Patterns**: Pub/Sub, Event Sourcing, CQRS

## Code Organization

### Folder Structure by Feature
```
src/
├── users/
│   ├── user.controller.js
│   ├── user.service.js
│   ├── user.repository.js
│   ├── user.model.js
│   └── user.validation.js
├── posts/
│   ├── post.controller.js
│   ├── post.service.js
│   └── ...
└── shared/
    ├── middleware/
    ├── utils/
    └── config/
```

**Pros**: Easy to find related code, scales well
**Cons**: Shared code can be tricky

### Folder Structure by Layer
```
src/
├── controllers/
│   ├── user.controller.js
│   └── post.controller.js
├── services/
│   ├── user.service.js
│   └── post.service.js
├── repositories/
│   ├── user.repository.js
│   └── post.repository.js
└── models/
    ├── user.model.js
    └── post.model.js
```

**Pros**: Clear technical boundaries
**Cons**: Hard to navigate in large apps

## Separation of Concerns

### ✅ Good Separation
- **Controllers**: HTTP concerns only
- **Services**: Business logic, no HTTP knowledge
- **Repositories**: Data access, return domain models
- **Models**: Data structure + validation
- **Middleware**: Cross-cutting concerns (auth, logging)

### ❌ Poor Separation
- Business logic in controllers
- HTTP responses in services
- Database queries scattered everywhere
- Validation mixed with business logic

## Scalability Considerations

### Horizontal Scaling
- [ ] Stateless services (no in-memory state)
- [ ] Shared cache (Redis, Memcached)
- [ ] Load balancing
- [ ] Database read replicas

### Performance Patterns
- [ ] **Caching**: Multi-layer caching strategy
- [ ] **Async Processing**: Background jobs for slow tasks
- [ ] **Database Optimization**: Indexes, query optimization
- [ ] **Rate Limiting**: Protect against abuse
- [ ] **CDN**: Serve static assets from edge

## Checklist Summary

Before finalizing architecture:
1. ✅ Follows SOLID principles?
2. ✅ Appropriate design patterns applied?
3. ✅ Clear separation of concerns?
4. ✅ Dependencies properly injected?
5. ✅ Easy to test?
6. ✅ Scalable and maintainable?
7. ✅ Code organized logically?
8. ✅ Avoids common anti-patterns?
9. ✅ Documentation clear?
10. ✅ Handles errors gracefully?
