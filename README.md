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

You'll need Docker installed (or equivalent so you can run `docker ps`).

## Get Started
```
git clone https://github.com/agardnerIT/otel-weaver-hands-on
cd otel-weaver-hands-on

# Pull down the weaver image
docker pull otel/weaver

# Validate the file syntax (should be OK on a fresh clone)
docker run --rm -v "$(pwd)":/work -w /work otel/weaver registry check -r /work
```

Now open 2 terminal windows:
- Terminal 1 will be running `weaver` in `live-check` mode. This is a server that accepts incoming telemetry and checks that telemetry against your conventions. After a certain (configurable) amount of time, the process will end (you can also press Ctrl+C to prematurely stop it) and a report will be generated
- Terminal 2 will be used to send demo telemetry to weaver. In this demo we send 3 log lines (each attached to it's own `Resource`.

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
