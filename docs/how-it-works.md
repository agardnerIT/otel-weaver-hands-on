# How it works

The story starts with the [model/manifest.yaml](https://github.com/agardnerIT/otel-weaver-hands-on/blob/main/model/manifest.yaml) file. This file says "we're defining a new schema called `acme` and also importing another pre-existing schema from the OpenTelemetry project."

[model/manifest.yaml](https://github.com/agardnerIT/otel-weaver-hands-on/blob/main/model/manifest.yaml) pairs with [model/imports.yaml](https://github.com/agardnerIT/otel-weaver-hands-on/blob/main/model/imports.yaml) and this file just tells weaver to import everything from the dependencies (i.e. the pre-existing OTEL semantic conventions).

## The attribute key

Now our custom part. In [model/cost.yaml](https://github.com/agardnerIT/otel-weaver-hands-on/blob/main/model/cost.yaml) we define a brand-new, never-before-seen attribute called `acme.cost.code` inside its own attribute group and we give some human readable descriptions. Importantly these examples and descriptions are NOT what weaver looks at to decide whether live telemetry is "correct" or not. This is PURE human readable metadata.

## The valid value

We have the key defined as `acme.cost.code` but how do we tell Weaver the valid value syntax? We do so in [policies/cost_code.rego](https://github.com/agardnerIT/otel-weaver-hands-on/blob/main/policies/cost_code.rego). This `.rego` file (pronounced RAY-GO) checks every piece of incoming telemetry and if lines 6-9 **ALL MATCH** then the rule fires:

1. The input is an attribute
2. The attribute has a name (key) of `acme.cost.code`
3. The value of `acme.cost.code` is a string
4. The value does **NOT** match the regex `^[A-Z]{3}[0-9]{4}$` (for example `ABC1234`)

If those 4 things are true, a result is sent back to weaver:

```json
{
  "id": "invalid_cost_code",
  "level": "violation",
  "context": { "<attribute-name>": "<attribute-value>" },
  "message": "acme.cost.code value <attribute-value> does not match ^[A-Z]{3}[0-9]{4}$"
}
```

## Required attribute (Part 2)

The same file has a second rule, `missing_cost_code`, which fires when a `Resource` has no `acme.cost.code` attribute at all. This is what rejects the unparsed log line in [Part 2](log-files.md): a log body with `cost.code=ABC12345` inside it is just text, not an attribute.
