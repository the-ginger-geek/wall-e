# Code style
- Use single quotes for strings.
- Use `camelCase` for variable names and functions.
- Use `cascalCase` for class names.
- Use as much from the flutter framework as possible, try avoid packages
- Use try/catch with comprehensive logging, include request IDs
- Always use final or const where possible
- Never log sensitive information
- Use the mukuru logger package for logging
- Write early return statements rather than deeply nested if statements
- Use the service locator pattern for dependency injection and constructors where it makes sense
- For testing use flutter's testing framework, Moqito for mocking

# Workflow
- Always run `flutter analyze` after writing a piece of code.
- Always create tests for new code.
- Always create widget tests for UI-related code.
- Run relevant tests after writing a piece of code.
- Always review readme when architecture changes and tests after changes
