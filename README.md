# Hands on with OpenTelemetry Weaver

> Weaver is a way to ensure your telemetry "looks right" and to give developers, SREs and teams a common language and set of tooling to make this easy enterprise-wide.

![weaver overview](assets/weaver-overview.png)

In this demo we imagine that we work for the `ACME Corporation` and define a standard `acme.cost.code` attribute (format `ABC1234`) that must be present on every telemetry record. You'll use OpenTelemetry Weaver to define that convention, then live-check telemetry against it.

## Documentation

The full walkthrough lives in [docs/](docs/index.md):

1. [Get started](docs/get-started.md)
2. [Interpreting output](docs/interpreting-output.md)
3. [How it works](docs/how-it-works.md)

To view it as a site locally:

```bash
pip install mkdocs-material
mkdocs serve
```
