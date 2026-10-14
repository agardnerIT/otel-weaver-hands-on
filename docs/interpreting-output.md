# Interpreting output

Weaver offers JSON and YAML output but by default we use the terminal output as it's more human-friendly.

In `Terminal 1` you should see 3 repeated output blocks of `Resource`, `Instrumentation scope` and `Log` - one per log line.

Focus on the `Log` output. That's where the `acme.cost.code` attribute lives. (The `Resource` blocks only differ by `service.name` and carry one `improvement` each, because the OpenTelemetry-added `service.instance.id` attribute isn't stable yet. That's fine, we should be aware of it, but it's nothing serious.)

## Record 1: compliant

```text
Instrumentation scope good

Log
    acme.cost.code = ABC1234
    code.file.path = /path/to/emit_test_logs.py
    code.function.name = <module>
    code.line.number = 28
```

Every attribute is green. The key exists and the value matches the cost code format.

## Record 2: invalid value

The second block has a more serious warning - a violation - and it's telling us that the `value` for `acme.cost.code` doesn't match the regex rule.

```text
Instrumentation scope bad-format

Log
    acme.cost.code = abc-12
        - [violation] acme.cost.code value 'abc-12' does not match ^[A-Z]{3}[0-9]{4}$
    code.file.path = /path/to/emit_test_logs.py
    code.function.name = <module>
    code.line.number = 28
```

## Record 3: invalid key

The third `Log` block has two violations. The key is wrong (`cost-code` doesn't exist anywhere in the ACME corp schema) and, as a result, the required `acme.cost.code` attribute is missing altogether.

```text
Instrumentation scope wrong-key

Log
    - [violation] Log record is missing required attribute 'acme.cost.code'
    cost-code = ABC1234
        - [violation] Attribute 'cost-code' does not exist in the registry.
    code.file.path = /path/to/emit_test_logs.py
    code.function.name = <module>
    code.line.number = 28
```

## Demo telemetry explained

- Log record 1 is `COMPLIANT` because it contains a log attribute with:
    - `acme.cost.code = ABC1234` = Valid ACME Corp cost code key and value
- Log record 2 is `NOT COMPLIANT` because it contains a log attribute with:
    - `acme.cost.code = abc-12` = Valid ACME Corp cost code key but an `invalid` value
- Log record 3 is `NOT COMPLIANT` because it contains a log attribute with:
    - `cost-code = ABC1234` = Valid `value` but an `invalid` key (should be `acme.cost.code` not `cost-code`), so the required attribute is also missing

## Summary

At the end of the output is a summary section. The telemetry received covered only 1.3% of the total available attributes (remember we're including the entire OTEL conventions too), and there were 6 pieces of advice given: 3 violations and 3 improvement suggestions, plus specifics on what that advice was.

```text
Advisories given
  - total: 6
  - advice level:
    - improvement: 3
    - violation: 3
  - advice type:
    - invalid_cost_code: 1
    - missing_attribute: 1
    - missing_cost_code: 1
    - not_stable: 3
  - advice message:
    - Attribute 'cost-code' does not exist in the registry.: 1
    - Attribute 'service.instance.id' is not stable; stability = development.: 3
    - Log record is missing required attribute 'acme.cost.code': 1
    - acme.cost.code value 'abc-12' does not match ^[A-Z]{3}[0-9]{4}$: 1

Registry coverage
  - total seen: 1.3%

✔ Performed live check for registry `/work/model`
```

## Programmatic access

All of this data is available as JSON or YAML output by using the `--output json` or `--output yaml` flag, meaning developers and SREs can bake these tests into CI/CD processes and pipelines.
