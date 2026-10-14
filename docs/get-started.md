# Get Started (Part 1)

```bash
git clone https://github.com/agardnerIT/otel-weaver-hands-on
cd otel-weaver-hands-on

# Create a Python virtual environment and install dependencies for later
python -m venv .
source bin/activate
pip install -r requirements.txt

# Pull down the weaver image
docker pull otel/weaver

# Validate the file syntax (should be OK on a fresh clone)
docker run --rm -v "$(pwd)":/work -w /work otel/weaver registry check -r /work/model
```

Now open 2 terminal windows:

- Terminal 1 will be running `weaver` in `live-check` mode. This is a server that accepts incoming telemetry and checks that telemetry against your conventions. After a certain (configurable) amount of time, the process will end (you can also press Ctrl+C to prematurely stop it) and a report will be generated.
- Terminal 2 will be used to send demo telemetry to weaver. In this demo we send 3 log lines (each attached to its own `Resource`).

## Terminal 1

Will run for 30s or until you press `Ctrl+C`:

```bash
docker run --rm -v "$(pwd)":/work -w /work -p 4317:4317 -p 4320:4320 otel/weaver registry live-check -r /work/model --advice-policies /work/policies --otlp-grpc-address 0.0.0.0 --inactivity-timeout 30
```

## Terminal 2

This Python file will send 3 log records to Weaver then exit.

```bash
python emit_test_logs.py
```

You will see:

```text
=== Sending: good log with attributes: {'service.name': 'team-a', 'acme.cost.code': 'ABC1234'} to Weaver ===
=== Sending: bad-format log with attributes: {'service.name': 'team-b', 'acme.cost.code': 'abc-12'} to Weaver ===
=== Sending: wrong-key log with attributes: {'service.name': 'team-c', 'cost-code': 'ABC1234'} to Weaver ===
```

When the script is finished, you can switch to Terminal 1 and press Ctrl+C to stop Weaver.

Next: [interpret the output](interpreting-output.md). Once you're comfortable, move on to [Part 2: checking log files](log-files.md).
