# Contributing to Docker Server PHP

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Use the bug report template** when creating a new issue
3. Include:
   - PHP version and Alpine version
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant logs or error messages

### Suggesting Features

1. **Check existing issues** for similar suggestions
2. **Use the feature request template**
3. Describe the use case and benefits
4. Consider backwards compatibility

### Pull Requests

1. **Fork the repository** and create a feature branch
2. **Follow the coding standards** (see below)
3. **Write tests** for new functionality
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description

## Development Setup

### Prerequisites

- Docker 20.10+
- Docker Compose v2
- Make
- Git

### Getting Started

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/docker-server-php.git
cd docker-server-php

# Create a feature branch
git checkout -b feature/your-feature-name

# Copy environment file
cp .env.example .env.dev

# Start development environment
make up
```

### Building and Testing

```bash
# Build all targets
make build-runtime
make build-dev
make build-prod

# Run tests
make test-targets

# Test specific target
make test-dev
```

## Coding Standards

### Dockerfile

- Use multi-stage builds
- Minimize layers where possible
- Pin versions for reproducibility
- Add comments for complex operations
- Follow [Hadolint](https://github.com/hadolint/hadolint) recommendations

### Shell Scripts

- Use `#!/bin/bash` or `#!/bin/sh` shebang
- Use `set -e` for error handling
- Quote variables: `"$VAR"`
- Use meaningful variable names
- Add comments for complex logic

### Configuration Files

- Use templates with environment variable substitution
- Provide sensible defaults
- Document all options

### Documentation

- Use clear, concise language
- Include code examples
- Keep README.md updated
- Add to MkDocs documentation for detailed guides

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(dockerfile): add PHP 8.5 support
fix(nginx): correct brotli module path
docs(readme): update installation instructions
```

## Pull Request Process

1. **Update documentation** for any changed functionality
2. **Add tests** for new features
3. **Ensure all tests pass**: `make test-targets`
4. **Update CHANGELOG.md** with your changes
5. **Request review** from maintainers

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Commit messages follow conventions
- [ ] No secrets or credentials committed

## Release Process

Releases are automated via GitHub Actions:

1. Maintainers create a git tag: `git tag v1.2.3`
2. Push the tag: `git push origin v1.2.3`
3. GitHub Actions builds and publishes images
4. Release notes are generated automatically

## Getting Help

- **Questions**: Open a [Discussion](https://github.com/host-uk/docker-server-php/discussions)
- **Bugs**: Open an [Issue](https://github.com/host-uk/docker-server-php/issues)
- **Security**: See [SECURITY.md](SECURITY.md)

## License

By contributing, you agree that your contributions will be licensed under the EUPL-1.2 license.
