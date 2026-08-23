# The contract format

The automation-identifier contract is a single JSON object that is the **shared
source of truth** between developers (who *set* identifiers on elements) and QA
(who *query* them in tests). This document is the normative spec.

## Structure

Keys are grouped by screen/component and addressed by a **dot path**. The
top-level value must be a JSON object.

```json
{
  "login": {
    "username_field": "login.username_field",
    "password_field": "login.password_field",
    "submit_button":  "login.submit_button"
  },
  "dashboard": {
    "balance_label": "dashboard.balance_label"
  }
}
```

The dot path of a value is the `.`-joined chain of keys from the root, e.g.
`login.submit_button`.

## Node kinds

A value is interpreted by its JSON type:

| JSON value                     | Meaning                                                        |
| ------------------------------ | ------------------------------------------------------------- |
| non-empty **string**           | **Leaf** — the string is the explicit identifier.             |
| empty **string** `""`          | **Leaf** — identifier auto-derived from the dot path.         |
| **null**                       | **Leaf** — identifier auto-derived from the dot path.         |
| **object** containing `"$id"`  | **Leaf with metadata** (see below).                           |
| **object** without `"$id"`     | **Group** — its keys are recursed into.                       |
| number / boolean / array       | **Error** — not a valid contract value.                       |

### Auto-derived identifiers

When the identifier is omitted (empty string, `null`, or a metadata object whose
`$id` is empty/null), it defaults to the dot path. So `login.submit_button` with
no explicit value resolves to the identifier `"login.submit_button"`.

Explicit values **win** — use them for legacy IDs QA already relies on:

```json
{ "login": { "submit_button": "legacy_login_cta" } }
```

### Leaf with metadata

To attach QA documentation to a leaf, use an object with the reserved `$id`
marker. Recognized metadata keys are `description`, `screen`, and `owner`; they
are ignored at runtime but flow into generated doc comments and exports.

```json
{
  "login": {
    "username_field": {
      "$id": "login.username_field",
      "description": "The username input",
      "screen": "Login",
      "owner": "auth-team"
    }
  }
}
```

Set `"$id"` to `null` to keep metadata while auto-deriving the identifier.

> **Reserved marker.** `$id` distinguishes a metadata leaf from a group. A group
> therefore cannot have a child literally named `$id`. The `$` prefix makes a
> real-world collision unlikely.

## Multiple files

Large apps may split the contract into several files merged **by namespace**.
Groups with the same name are merged recursively; on identical dot paths the
later file wins. Pass multiple paths to any command:

```sh
tandha generate Contracts/login.json Contracts/dashboard.json --output Generated.swift
```

## Determinism

Output (flattened entries, generated code, exports) is always ordered by sorting
keys, regardless of the order they appear in the JSON — so diffs stay stable.
