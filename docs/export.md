# Export

`tandha export` emits the identifier contract in formats external QA tooling can
consume, so a cross-platform Appium / Katalon / Selenium-family suite stays in
lockstep with the app — no hand-copying strings.

```bash
tandha export automation-ids.json --format <name> [--output <file>]
```

## Formats

=== "JSON"

    Flat `{ "dot.path": "identifier" }` map, sorted by key — the
    lowest-common-denominator any tool can load.

    ```bash
    tandha export automation-ids.json --format json
    ```

    ```json
    {
      "dashboard.balance_label": "dashboard.balance_label",
      "login.submit_button": "login.submit_button",
      "login.username_field": "login.username_field"
    }
    ```

=== "CSV"

    `key,identifier,description,screen,owner` with RFC-4180 quoting — handy for
    spreadsheets and QA documentation.

    ```bash
    tandha export automation-ids.json --format csv
    ```

    ```csv
    key,identifier,description,screen,owner
    login.submit_button,login.submit_button,Primary sign-in button,Login,auth-team
    login.username_field,login.username_field,,,
    ```

=== "Java page object"

    An Appium/Katalon-friendly Java class of `By` locators mirroring the namespace
    tree.

    ```bash
    tandha export automation-ids.json --format java
    ```

    ```java
    public static final class Login {
        public static final By usernameField =
            AppiumBy.accessibilityId("login.username_field");
        public static final By submitButton =
            AppiumBy.accessibilityId("login.submit_button");
    }
    ```

## Add your own format

Each exporter is a single self-contained type conforming to `Exporter`, registered in
`Exporters.all`. A new format (Python page object, `.properties`, WebdriverIO locator
map, …) is an ideal first contribution — see the
[good first issues](good-first-issues.md).

!!! note "Same contract, both stacks"
    The identifiers exported here are the exact `accessibility id` values your
    [XCUITest](xcuitest.md) suite queries. tandha does not run the automation — it
    keeps every stack pointed at one contract.
