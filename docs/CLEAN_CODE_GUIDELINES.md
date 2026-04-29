# Clean Code & Project Standards

This document defines the essential coding rules to optimize readability, maintainability, and scalability of the project following the rapid development phase.

## 1. General Principles

- **KISS (Keep It Simple, Stupid):** Keep code as simple as possible. Avoid over-engineering.
- **DRY (Don't Repeat Yourself):** Do not duplicate code. If a logic block appears more than twice, extract it into a function or shared component.
- **YAGNI (You Ain't Gonna Need It):** Do not write code for features that "might be needed" in the future. Implement only what is currently required.
- **Language:** All code, comments, documentation, and `.md` files must be in **English**.

## 2. Naming Conventions

- **Variables & Functions:** Use `camelCase`. Names should be descriptive and meaningful. Avoid obscure abbreviations (e.g., use `currentUser` instead of `usr`).
- **Classes & Types:** Use `PascalCase`.
- **Files:** Use `snake_case`.
- **Booleans:** Should start with `is`, `has`, or `should` (e.g., `isVisible`, `hasData`).

## 3. Function & Method Constraints

- **UI Functions (Build methods, UI Helpers):**
    - Target length: **20 to 40 lines**.
    - Buffer: Max **+5 lines** allowed in exceptional cases.
    - If it exceeds this, split it into smaller sub-widgets.
- **Logic Functions (Business logic, Data processing):**
    - Target length: Max **30 lines**.
    - Buffer: Max **+5 lines** allowed.
- **Single Responsibility Principle (SRP):** Each function must do exactly **one thing**.
- **Parameters:** Limit the number of parameters (ideally <= 3). Use named parameters for clarity when more are needed.

## 4. Classes & Components

- **File Length:** A single file should not exceed **300 lines**. If it does, consider splitting it into smaller files or sub-components.
- **Flutter Widgets:**
    - Avoid excessive `_buildXxx()` private methods in the same class. Extract them into separate `StatelessWidget` classes.
    - The `build` method should be concise, primarily containing high-level layout.
- **Independent ViewModels:**
    - Complex child widgets or dialogs (e.g., a dialog with its own business logic, complex validation, or asynchronous tasks beyond simple confirmation) should have their own **ViewModel**.
    - This approach reduces the complexity of the parent ViewModel and increases component reusability.
    - Data from these independent units should be returned to the parent page/viewmodel upon completion.
- **Separation of Concerns:** ViewModels must not contain UI-related logic (e.g., `BuildContext`, `Color`, `IconData`).

## 5. Comments & Documentation

- **Self-documenting Code:** Prioritize writing clear code that explains itself without comments.
- **Comment "Why" not "What":** Do not explain what the code is doing (the code should be clear enough). Explain **why** a specific approach was taken if it is non-obvious or complex.
- **TODOs:** Use `// TODO: description` to mark areas for future improvement.

## 6. Error Handling

- Never leave a `catch` block empty. At minimum, log the error or notify the user.
- Prefer `try-catch` blocks at the boundaries of external communication (API, Database, File System).

---

> [!TIP]
> Clean code is not just code that works; it is code that your teammates (or your future self) can read, understand, and modify without unnecessary friction.
