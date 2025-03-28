# Architecture decision records

An [architecture
decision](https://cloud.google.com/architecture/architecture-decision-records)
is a software design choice that evaluates:

- a functional requirement (features).
- a non-functional requirement (technologies, methodologies, libraries).

The purpose is to understand the reasons behind the current architecture, so
they can be carried-on or re-visited in the future.

## Problem Specification: Key-Value Store with Scoped Keys and Dynamic Typing in Dart

**Problem Summary**  
Implement a key-value store library in Dart where all keys follow the format `scope:name`. The scope is predefined and mandatory, while the name follows a relaxed convention similar to programming variable names, but may support multilingual characters. Values are stored as strings but represent multiple primitive types dynamically.

**Core Requirements**

- Keys must follow the format `scope:name`, where:
  - `scope` is defined at store initialization and enforced.
  - `name` is flexible but should be interpretable as variable-like names, including support for non-English characters.
- Values are stored as strings but support dynamic interpretation as types like bool, int, double, etc.
- Type schema is not defined statically but must be enforced dynamically during read/write via typed accessors (e.g., `getAsBool`, `setAsInt`).
- Construction must allow configuration of:
  - Allowed scopes.
  - Behavior on invalid reads (e.g., throw, log, return default).
- Store should support:
  - In-place transformations on values (e.g., incrementing an int).
  - Bulk clearing, either entirely or via a filter on key patterns.
  - Loading/saving in multiple Dart-supported formats (e.g., JSON, Map).
  - Appending data instead of replacing.
- Support state management through:
  - Savepoints and restore points.
  - Optional history tracking of changes.
- Event tracking should be available to enable downstream analysis of value changes or operations.

**Use Cases**

- Reading a value as a specific type (e.g., `getAsInt("env:retry_count")`).
- Writing a new variable with dynamic typing (`set("query:limit", "10")`).
- Appending new key-values from a Dart Map without overwriting existing entries.
- Clearing all values under a given scope (`clearWhere(scope: "env")`).
- Storing a checkpoint of the current state and restoring it later (`savepoint("v1")` → `restore("v1")`).
- Monitoring invalid value formats without exceptions (`getAsBool` with fallback and metrics).
- Tracking a history of all applied updates for audit purposes.
- Loading or saving the full store in JSON, YAML, or other Dart-compatible formats.

**Edge Cases**

- Writing a key with an undefined scope should be disallowed.
- Reading a non-parsable value as a specific type should follow the chosen failure strategy.
- Incrementing a non-numeric string should be treated as a failure.
- Restoring a point after bulk-clearing should fully recover the prior state.
- Appending data with duplicate keys should follow clear override/merge rules.
- Support for nested or hierarchical keys beyond `scope:name`.

**Limitations**

- The store should not infer types automatically—typed access must be explicit.
- Schema validation is limited to per-access operations, not pre-defined types.
- Does not enforce full i18n of keys—minimal support for multilingual variable names is acceptable.
- Does not persist to disk unless explicitly exported; memory-backed by default.
- Event store features should be lightweight—deep querying or indexing is not required.
