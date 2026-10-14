# Hands on with OpenTelemetry Weaver

In this demo we imagine that we work for the `ACME Corporation` and we want to define a new standard attribute across our organisation to represent a `cost code`. Our organisation mandates that this cost code be present on every telemetry record so that we can efficiently cross charge storage costs by cost centre. Furthermore, our organisation mandates that every cost code has the syntax: `[UPPERCASE_ALPHA]{3}[NUMBERS][4]` for example: `ABC1234`.

That's easy to say, harder to do in a large enterprise:

- How does ACME Corp define this rule in a place that everyone can access? Word of mouth? A word doc on Sharepoint? A company wide email?
- How does ACME Corp make it easier for teams to adopt this standard?
- How does ACME Corp make it easy for teams so "self-audit" to ensure their own telemetry is in compliance with the org policy?
- How does ACME Corp ensure that standards don't slip after a while?

The answer is to define a standard convention that the entire company agrees upon in an easily digestible format and provide tooling so teams can audit their own telemetry to ensure they're up to standard.

This is what the OpenTelemetry Weaver project offers.

## Prerequisites

You'll need Python and Docker installed (or equivalent so you can run `docker ps`).


## Get Started
```
git clone https://github.com/agardnerIT/otel-weaver-hands-on
cd otel-weaver-hands-on

# Create a Python virtual environment and install dependencies for later
python -m venv .
source bin/activate
pip install -r requirements.txt

# Pull down the weaver image
docker pull otel/weaver

# Validate the file syntax (should be OK on a fresh clone)
docker run --rm -v "$(pwd)":/work -w /work otel/weaver registry check -r /work
```

Now open 2 terminal windows:
- Terminal 1 will be running `weaver` in `live-check` mode. This is a server that accepts incoming telemetry and checks that telemetry against your conventions. After a certain (configurable) amount of time, the process will end (you can also press Ctrl+C to prematurely stop it) and a report will be generated
- Terminal 2 will be used to send demo telemetry to weaver. In this demo we send 3 log lines (each attached to it's own `Resource`.

### Terminal 1
Will run for 30s or until you press `Ctrl+C`:

```
docker run --rm -v "$(pwd)":/work -w /work -p 4317:4317 -p 4320:4320 otel/weaver registry live-check -r /work --advice-policies /work/policies --otlp-grpc-address 0.0.0.0 --inactivity-timeout 30
```

### Terminal 2

```
python emit_test_logs.py
```

You will see:
```
=== Sending: good log with attributes: {'service.name': 'team-a', 'acme.cost.code': 'ABC1234'} to Weaver ===
=== Sending: bad-format log with attributes: {'service.name': 'team-b', 'acme.cost.code': 'abc-12'} to Weaver ===
=== Sending: wrong-key log with attributes: {'service.name': 'team-c', 'cost-code': 'ABC1234'} to Weaver ===
```

When the script is finished, you can switch to Terminal 1 and press Ctrl + C to stop Weaver.

## Interpreting output

Weaver offers JSON and YAML output but by default we use the terminal output as it's more human-friendly.

In `Terminal 1` you should see 3 repeated output blocks of `Resource`, `Instrumentation scope` and `Log` - one per log line.

Focus on the `Resource` output.

```
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

The second block has a more serious warning - a violation - and it's telling us that the `value` for `acme.cost.code` doesn't match the regex rule.

```
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

The third `Resource` block has a different violation - this one is telling us that the key is wrong and that `cost-code` doesn't exist anywhere in the ACME corp schema.

```
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

## Demo Telemetry Explained

* Log record 1 is `COMPLIANT` because it contains a `Resource` attribute with:
    * `service.name = team-a` = Valid OpenTelemetry attribute name and value
    * `acme.cost.code = ABC1234` = Valid ACME Corp code code and value
* Log record 2 is `NOT COMPLIANT` because it contains a `Resource` attribute with:
    * `service.name = team-b` = Valid OpenTelemetry attribute name and value
    * `acme.cost.code = abc-12` = Valid ACME Corp code code and but an `invalid` value
* Log record 3 is `NOT COMPLIANT` because it contains a `Resource` attribute with:
    * `service.name = team-c` = Valid OpenTelemetry attribute name and value
    * `cost.code = ABC1234` = Valid `value` but an `invalid` key (should be `acme.cost.code` not `cost.code`
