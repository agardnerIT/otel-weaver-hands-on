# Interpreting output

Weaver offers JSON and YAML output but by default we use the terminal output as it's more human-friendly.

In `Terminal 1` you should see 3 repeated output blocks of `Resource`, `Instrumentation scope` and `Log` - one per log line.

Focus on the `Resource` output.

## Record 1: compliant

```text
Resource
    telemetry.sdk.language = python
    telemetry.sdk.name = opentelemetry
    telemetry.sdk.version = 1.45.1
    service.instance.id = 4225e7a7-66d8-4b83-bb87-934ac7e23988
        - [improvement] Attribute 'service.instance.id' is not stable; stability = development.
    service.name = team-a
    acme.cost.code = ABC1234
```

The first block should only have one yellow `improvement` telling you that one of the OpenTelemetry automatically-added attributes `service.instance.id` is not yet declared as stable. That's fine, we should be aware of it, but it's nothing serious. Other than that, all other attributes are green and OK.

## Record 2: invalid value

The second block has a more serious warning - a violation - and it's telling us that the `value` for `acme.cost.code` doesn't match the regex rule.

```text
Resource
    telemetry.sdk.language = python
    telemetry.sdk.name = opentelemetry
    telemetry.sdk.version = 1.45.1
    service.instance.id = 4225e7a7-66d8-4b83-bb87-934ac7e23988
        - [improvement] Attribute 'service.instance.id' is not stable; stability = development.
    service.name = team-b
    acme.cost.code = abc-12
        - [violation] acme.cost.code value 'abc-12' does not match ^[A-Z]{3}[0-9]{4}$
```

## Record 3: invalid key

The third `Resource` block has a different violation - this one is telling us that the key is wrong and that `cost-code` doesn't exist anywhere in the ACME corp schema.

```text
Resource
    telemetry.sdk.language = python
    telemetry.sdk.name = opentelemetry
    telemetry.sdk.version = 1.45.1
    service.instance.id = 4225e7a7-66d8-4b83-bb87-934ac7e23988
        - [improvement] Attribute 'service.instance.id' is not stable; stability = development.
    service.name = team-c
    cost-code = ABC1234
        - [violation] Attribute 'cost-code' does not exist in the registry.
```

## Demo telemetry explained

- Log record 1 is `COMPLIANT` because it contains a `Resource` attribute with:
    - `service.name = team-a` = Valid OpenTelemetry attribute name and value
    - `acme.cost.code = ABC1234` = Valid ACME Corp cost code key and value
- Log record 2 is `NOT COMPLIANT` because it contains a `Resource` attribute with:
    - `service.name = team-b` = Valid OpenTelemetry attribute name and value
    - `acme.cost.code = abc-12` = Valid ACME Corp cost code key but an `invalid` value
- Log record 3 is `NOT COMPLIANT` because it contains a `Resource` attribute with:
    - `service.name = team-c` = Valid OpenTelemetry attribute name and value
    - `cost-code = ABC1234` = Valid `value` but an `invalid` key (should be `acme.cost.code` not `cost-code`)

## Summary

At the end of the output is a summary section that shows this check took `35s` to complete, the telemetry received covered only 1.3% of the total available attributes (remember we're including the entire OTEL conventions too), and there were 5 pieces of advice given: 2 violations and 3 improvement suggestions, plus specifics on what that advice was.

```text
Advisories given
  - total: 5
  - advice level:
    - improvement: 3
    - violation: 2
  - advice type:
    - invalid_cost_code: 1
    - missing_attribute: 1
    - not_stable: 3
  - advice message:
    - Attribute 'cost-code' does not exist in the registry.: 1
    - Attribute 'service.instance.id' is not stable; stability = development.: 3
    - acme.cost.code value 'abc-12' does not match ^[A-Z]{3}[0-9]{4}$: 1

Registry coverage
  - total seen: 1.3%

✔ Performed live check for registry `/work`

Total execution time: 35.302828683s
```

## Programmatic access

All of this data is available as JSON or YAML output by using the `--output json` or `--output yaml` flag, meaning developers and SREs can bake these tests into CI/CD processes and pipelines.
