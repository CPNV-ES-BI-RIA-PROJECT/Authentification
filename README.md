# Authentification Composant
## Description
This component is responsible for handling user Session in the application. It provides functionalities for user login.

## Features for other components
- User login with email and password
- Bearer token generation for authenticated sessions
- Validation of user credentials

## Diagram

```mermaid
classDiagram
  class Account {
    -String email
    -String passwordDigest
    +findByEmail(email)$
    +hasSecurePassword()
    +verifyPassword(password)
  }

  class ISessionService {
    <<interface>>
    +login(email, password)
    +validateToken(token)
    +revokeToken(token)
  }

  class SessionService {
    +login(email, password)
    +validateToken(token)
    +revokeToken(token)
  }

  class SessionController {
    +index(request)
    +post(request)
    +delete(request)
  }

  SessionService ..|> ISessionService
  SessionService --> Account
  SessionController --> SessionService
```

## Sequence
### User Login Sequence

```mermaid
sequenceDiagram
  participant User
  participant SessionController
  participant SessionService
  participant Account

  User->>SessionController: POST /sessions with email and password
  SessionController->>SessionService: login(email, password)
  SessionService->>Account: find_by_email(email)
  Account-->>SessionService: account
  SessionService->>Account: verify(password)
  Account-->>SessionService: true/false
  SessionService-->>SessionController: token or error
  SessionController-->>User: response with token or error message
```

### Token Validation Sequence

```mermaid
sequenceDiagram
  participant User
  participant SessionController
  participant SessionService
  participant Account

  User->>SessionController: GET /sessions with Bearer token in authorization header
  SessionController->>SessionService: validateToken(token)
  SessionService->>Account: get user
  Account-->>SessionService: user or error not found
  SessionService-->>SessionController: valid/invalid with user data
  SessionController-->>User: response with user info or error
```