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

## Query Language for Store Manipulation

**Purpose**

Introduce a structured query language to update the key-value store using simple, readable commands. This query language enables user-submitted input to manipulate store values within defined constraints, with safety and control mechanisms in place.

**Syntax Overview**  
The language uses a semicolon-separated sequence of simple operations. Examples include:

- `set env:name1 to 2;`
- `inc env:counter 1;`
- `dec env:counter2 1;`
- `clear env:name3;`
- `set env:name21 truthy;`
- `list append env:mylist 2;`
- `set append env:myset blue;`

**Supported Commands**

- `set scope:name to value`: Sets the variable to a value.
- `inc scope:name amount`: Increments numeric value by an amount.
- `dec scope:name amount`: Decrements numeric value by an amount.
- `clear scope:name`: Removes the variable from the store.
- `list append scope:name value`: Appends a value to a list variable.
- `set scope:name value`: Appends a value to a set variable.

**Value Types**

- Only integer, float, and predefined enums (e.g., `truthy`) are supported.
- Enum mappings (e.g., `truthy` → `T`) must be configured externally and are validated during query processing.
- Free text string values are disallowed to reduce injection or misuse risks.

**Data Serialization for List/Set Types**

- Configuration must define how compound types (list, set) are stored as strings.
- Supported strategies may include delimiter-separated strings, JSON arrays, or indexed key variants.
- Serialization and deserialization strategies must be enforced consistently at both write and read time.

**Query Components**

- **Lexer**: Tokenizes commands into structured operations.
- **Semantic Analyzer**: Validates command structure, types, allowed scopes, and enum values.
- **Executor**: Applies validated commands to the store.

**Security and Safety**

- User-submitted queries are not trusted and must be parsed strictly.
- Only predefined scopes, commands, and values are permitted.
- Optional schema rules can define acceptable keys and value types.
- Error handling strategy (ignore, reject, log) should be configurable for invalid queries.

**Limitations**

- Queries do not support arbitrary text strings as values.
- Nested or chained commands are not allowed (e.g., no `if` or `while`).
- Only primitive operations are supported; no function calls or complex expressions.
- Scope must be explicit or defaulted; ambiguous commands are rejected.
- Enum translation must be exact and case-sensitive unless configured otherwise.

**Enum Definitions**

- Enum values must be provided as a mapping at query engine initialization. Example:
  - `truthy → T`
  - `falsy → F`
  - `on → 1`
  - `off → 0`
- Enums must be explicitly defined per use case; undefined enums are rejected.
- Case sensitivity should be configurable (e.g., `truthy` vs `Truthy`).
- Mappings are one-way: the query language uses enums, and the store receives the translated value.

**List/Set Serialization Formats**

At query engine setup, one serialization format must be selected for list/set types:

- **Delimited Strings**

  - Values stored as `value1,value2,value3`
  - Delimiter (e.g., comma, semicolon) must be defined and consistent
  - Escaping rules (if any) should be specified

- **JSON Strings**
  - Values stored as valid JSON arrays: `["value1", "value2"]`
  - Parsing uses Dart JSON utilities
  - Safer but more verbose

**Default Behavior (if unspecified)**

- Enums: Case-sensitive, enum validation enabled
- Lists: Comma-separated string with no escaping
- Sets: Treated as lists with uniqueness enforced before storing
