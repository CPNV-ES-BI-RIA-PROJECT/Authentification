# Authentication Service — Usage Guide

This guide explains how to run the authentication component and how an orchestrator or upstream service should call it. For architecture or diagrams, refer to other docs (e.g., `docs/class_diagram.md`).

## Table of Contents

- [Authentication Service — Usage Guide](#authentication-service--usage-guide)
  - [Table of Contents](#table-of-contents)
  - [1. What This Service Does](#1-what-this-service-does)
  - [2. Configuration Via `.env`](#2-configuration-via-env)
  - [3. Default Configuration](#3-default-configuration)
  - [4. Running The Service](#4-running-the-service)
    - [Start the Sinatra server](#start-the-sinatra-server)
    - [Override configuration](#override-configuration)
  - [5. Running With Docker](#5-running-with-docker)
  - [6. API Overview](#6-api-overview)
  - [7. Recommended Orchestrator Flow](#7-recommended-orchestrator-flow)
  - [8. Endpoint Details](#8-endpoint-details)
    - [8.1 Inspect session](#81-inspect-session)
    - [8.2 Create session (login)](#82-create-session-login)
    - [8.3 Delete session (logout)](#83-delete-session-logout)
  - [9. Example Session](#9-example-session)
    - [Step 1: log in](#step-1-log-in)
    - [Step 2: reuse token](#step-2-reuse-token)
    - [Step 3: log out](#step-3-log-out)
  - [10. Error Handling](#10-error-handling)
  - [11. Adapter Coverage](#11-adapter-coverage)
    - [IAM adapters (`src/factory/iam_adapter_factory.rb`)](#iam-adapters-srcfactoryiam_adapter_factoryrb)
    - [Token adapters (`src/factory/token_adapter_factory.rb`)](#token-adapters-srcfactorytoken_adapter_factoryrb)
  - [12. Environment Variable Summary](#12-environment-variable-summary)
  - [13. Typical Integration Pseudocode](#13-typical-integration-pseudocode)

---

## 1. What This Service Does

The component exposes `/api/v1/sessions` (via `SessionsController`) and `/api/docs` (via `DocsController`). It handles login, session inspection, and logout, issuing bearer tokens for authenticated conversations. You can instantiate `SessionsService` directly from another Ruby app to leverage the same adapters.

---

## 2. Configuration Via `.env`

Copy `.env.example` to `.env` and edit the variables you need:

```bash
cp .env.example .env
```

The `dotenv` gem loads these values when the Sinatra app boots in `src/http/start.rb`.

---

## 3. Default Configuration

```env
default IAM_PROVIDER=cognito
default TOKEN_PROVIDER=bearer
JWT_EXPIRATION_TIME=3600
AWS_REGION=us-east-1
```

`SessionsService` falls back to Cognito for IAM and a symmetric bearer adapter for tokens if you do not override `IAM_PROVIDER` or `TOKEN_PROVIDER`.

---

## 4. Running The Service

### Start the Sinatra server

Install Ruby dependencies and launch the HTTP server:

```bash
bundle install
rake http
```

By default Sinatra listens on port 4567 (see `README.md`). The Swagger UI is available at `/api/docs` and the generated OpenAPI JSON at `/api/docs/openapi.json`.

### Override configuration

Set environment variables before `rake http` to switch providers or adjust expiration, e.g.: `IAM_PROVIDER=fake TOKEN_PROVIDER=bearer JWT_EXPIRATION_TIME=7200 bundle exec rake http`.

---

## 5. Running With Docker

Run `docker compose up --build` (see `docs/deployment.md`) to build the containerized service. The same API surface remains available at `http://localhost:4567` (or the port you map).

---

## 6. API Overview

Base path:

```text
/api/v1/
```

Endpoints:

* `GET /api/v1/sessions` (token inspection)
* `POST /api/v1/sessions` (login)
* `DELETE /api/v1/sessions` (logout)
* `GET /api/v1/health` (optional health check)

Swagger UI: `/api/docs`
OpenAPI JSON: `/api/docs/openapi.json`

---

## 7. Recommended Orchestrator Flow

1. Request `POST /api/v1/sessions` with `username`/`password` to receive a bearer token.
2. Use `Authorization: Bearer ...` for subsequent `GET` or `DELETE` calls.
3. If you need to revoke the token (e.g., on logout), call `DELETE /api/v1/sessions` with the same header.
4. Inspect sessions to confirm the current authenticated user with `GET /api/v1/sessions`.

---

## 8. Endpoint Details

### 8.1 Inspect session

*Requires `Authorization` header.*

`GET /api/v1/sessions` returns the decoded payload from the bearer token. Responses:

* `200 OK` with `{ "username": "alice", "provider": "fake" }`
* `401 Unauthorized` if the header is missing, expired, malformed, or revoked.

### 8.2 Create session (login)

`POST /api/v1/sessions` accepts `application/x-www-form-urlencoded` data:

```
username=alice&password=secret
```

Responses:

* `200 OK` with `{ "token": "Bearer ..." }` when the IAM adapter accepts the credentials.
* `400 Bad Request` if required parameters are missing.
* `401 Unauthorized` if credentials are invalid.

### 8.3 Delete session (logout)

`DELETE /api/v1/sessions` expects the same `Authorization` header. The service revokes the token (to prevent reuse) and returns `200 OK` on success or `401 Unauthorized` when the token is rejected.

---

## 9. Example Session

### Step 1: log in

```bash
curl -X POST http://localhost:4567/api/v1/sessions -d "username=user1&password=password1"
```

This returns a JSON bearer token (e.g., `Bearer ey...`).

### Step 2: reuse token

```bash
curl http://localhost:4567/api/v1/sessions -H "Authorization: Bearer ey..."
```

This returns the stored payload (username/provider).

### Step 3: log out

```bash
curl -X DELETE http://localhost:4567/api/v1/sessions -H "Authorization: Bearer ey..."
```

This revokes the token; subsequent `GET` calls fail with `401`.

---

## 10. Error Handling

Controllers rescue `TokenError` subclasses (`AuthorizationTokenIsMissingError`, `InvalidTokenFormatError`, `InvalidTokenError`, `ExpiredTokenError`, `RevokedTokenError`) to provide the correct 401/400 HTTP status. `SessionsService` raises `UnknownAdapterTypeError` for unsupported providers, and IAM adapters raise `MissingCredentialsError` if required AWS environment variables are absent.

---

## 11. Adapter Coverage

### IAM adapters (`src/factory/iam_adapter_factory.rb`)

* `fake`: accepts `user1/password1` and `user2/password2` (local dev).
* `cognito`: calls AWS Cognito (`Aws::CognitoIdentityProvider`) with optional client secret hash.
* `aws`: verifies access key/secret via `Aws::IAM::Client`.

### Token adapters (`src/factory/token_adapter_factory.rb`)

* `bearer`: issues HS256-signed JWTs, stores secret in `storages/secret`, tracks revocations in `storages/revoked_tokens`.
* `aws4-hmac-sha256`: read-only validator for AWS SigV4 headers (no token creation or revocation).

---

## 12. Environment Variable Summary

| Variable                                            | Default     | Purpose                                                     |
| --------------------------------------------------- | ----------- | ----------------------------------------------------------- |
| `IAM_PROVIDER`                                      | `cognito`   | Selects the IAM adapter (`fake`, `cognito`, or `aws`).      |
| `TOKEN_PROVIDER`                                    | `bearer`    | Selects the token adapter (`bearer` or `aws4-hmac-sha256`). |
| `JWT_EXPIRATION_TIME`                               | `3600`      | Bearer token lifetime in seconds.                           |
| `AWS_REGION`                                        | `us-east-1` | AWS region for IAM/Cognito clients.                         |
| `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`        | —           | Required when using `aws` or `cognito`.                     |
| `AWS_COGNITO_CLIENT_ID`, `AWS_COGNITO_USER_POOL_ID` | —           | Required for the Cognito adapter.                           |
| `AWS_COGNITO_CLIENT_SECRET`                         | optional    | Adds `SECRET_HASH` to Cognito auth.                         |

---

## 13. Typical Integration Pseudocode

```ruby
service = SessionsService.new

token = service.login(username, password)
# call callers with Authorization: "Bearer #{token}"
payload = service.current("Bearer #{token}")
service.logout("Bearer #{token}")
```

Use the same adapter configuration when you instantiate `SessionsService` inside another Ruby process so the token parsing logic remains centralized.
