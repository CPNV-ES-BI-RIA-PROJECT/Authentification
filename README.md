# Authentification Composant
## Description
This component is responsible for handling user Session in the application. It provides functionalities for user login.

## Features for other components
- User login with email and password
- Bearer token generation for authenticated sessions
- Validation of user credentials

## Getting Started

### Prerequisites

- Ruby 3.4.7
- Bundler 2.6.9

### Configuration

Copy the `.env.example` file to `.env` and fill in the required environment variables:

```bash
cp .env.example .env
```

## Deployment

### On dev environment

First get the dependencies:
```bash
bundle config set with 'develpment'
bundle install
```
Then you can start the server:
```bash
rake http
```
For testing, you can run:
```bash
rake test
```

### On integration environment

TODO: add the steps to deploy on integration environment

## Directory structure

* Tip: try the tree bash command

```shell
.
├── docs                  # Documentation files
├── src                   # Source code
│   ├── factory           # Factory files for creating model objects
│   ├── http              # HTTP related code
│   │   ├── config.rb     # Configuration for HTTP server
│   │   ├── controllers   # HTTP controllers for handling requests
│   │   └── start.rb      # Entry point for starting the HTTP server
│   ├── model             # Model files representing the data structures and business logic
│   └── service           # Service files for handling business logic and interactions between models
└── test                  # Test files for unit and integration testing
```

## Collaborate

### Commit Guidelines

Use conventional commit messages to describe your changes. 
- https://www.conventionalcommits.org/en/v1.0.0/
- https://gist.github.com/qoomon/5dfcdf8eec66a051ecd85625518cfd13#file-conventional-commits-cheatsheet-md

Current commit types include:
Changes relevant to the API or UI:
- `feat`: Commits that add, adjust or remove a new feature to the API or UI
- `fix`: Commits that fix an API or UI bug of a preceded feat commit
- `refactor`: Commits that rewrite or restructure code without altering API or UI behavior
- `perf`: Commits are special type of refactor commits that specifically improve performance
- `style`: Commits that address code style (e.g., white-space, formatting, missing semi-colons) and do not affect application behavior
- `test`: Commits that add missing tests or correct existing ones
- `docs`: Commits that exclusively affect documentation
- `build`: Commits that affect build-related components such as build tools, dependencies, project version, ...
- `ops`: Commits that affect operational aspects like infrastructure (IaC), deployment scripts, CI/CD pipelines, backups, monitoring, or recovery procedures, ...
- `chore`: Commits that represent tasks like initial commit, modifying .gitignore, ...

### How to propose a new feature (issue, pull request)

1. Create an issue describing the feature you want to propose, including the problem it solves and any relevant details.
2. If you want to implement the feature yourself, create a new branch from the main branch and name it appropriately (e.g., `feature/new-feature-name`) or fork the repository if you don't have write access to the main repository.
3. Implement the feature in your branch, following the commit guidelines for any commits you make.
4. Once your implementation is complete, push your branch to the repository and create a pull request (PR) against the main branch.

### Branching Strategy

We follow the Git Flow branching strategy, which includes the following branches:
- `main`: The main branch that contains the production-ready code.
- `develop`: The development branch where all feature branches are merged before being merged into main.
- `feature/*`: Branches for developing new features. These branches are created from the develop branch and are merged back into develop when the feature is complete.
- `release/*`: Branches for preparing a new release. These branches are created from develop and are merged into main and develop when the release is ready.
- `hotfix/*`: Branches for fixing critical bugs in production. These branches are created from main and are merged into main and develop when the hotfix is complete.

* For more details on Git Flow, see: https://nvie.com/posts/a-successful-git-branching-model/

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

* [Ethann Schneider](mailto:ethann.schneider@eduvaud.ch)