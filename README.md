# Community Learning Center Management System

## Project Information
- Subject: Mobile Development
- Language: Dart
- Application type: Console application
- Scenario: Community Learning Center Management System

## Features
1. Add learning resources.
2. Register participants.
3. Borrow and return learning resources.
4. View learning resources.
5. View registered participants.
6. View transaction history.
7. View all records.

## Object-Oriented Programming Concepts
- **Encapsulation:** Private fields such as `_category`, `_isBorrowed`, and `_email` are accessed through getters, setters, and methods.
- **Inheritance:** `LearningResource` and `Participant` extend the abstract `CenterRecord` class.
- **Polymorphism:** Both subclasses are stored and displayed through the shared `CenterRecord` parent type and their overridden `describe()` methods.
- **Abstraction:** `CenterRecord` is an abstract class with an abstract `describe()` method.
- **Mixin:** `Timestamped` provides reusable creation-time information to resources, participants, and transactions.
- **Collections:** A `List` stores resources and transactions; a `Map` stores participants by ID.

## How to Run
1. Install the Dart SDK.
2. Save the source file as `main.dart`.
3. Open a terminal in the folder containing `main.dart`.
4. Run:

```bash
dart run main.dart
```

## Sample Test Scenarios
1. **Valid input:** Add a resource, register a participant, borrow the resource, and view the transaction history.
2. **Invalid menu input:** Enter a letter such as `abc` or a number outside 0–8. The program displays an error and continues.
3. **Invalid record input:** Try borrowing with an unknown participant/resource ID, or try borrowing a resource that is already borrowed. The program displays an appropriate message without crashing.

## Notes
- Resource IDs are generated automatically (for example, `R001`).
- Participant IDs are generated automatically (for example, `P001`).
- Email input is checked for a basic `@` and `.` format.
