# JMeter Learning Project

A hands-on practice repository for learning **Apache JMeter** from basic load tests through correlation, realistic scenarios, distributed runs, and CI/CD integration.

Labs use the public [JSONPlaceholder](https://jsonplaceholder.typicode.com/) API as a safe target for HTTP GET/POST exercises.

The layout follows a phased learning plan: test plans grouped by skill level, external data under `data/`, local results and HTML dashboards under `results/` and `reports/`, and (later) GitHub Actions workflows under `ci-cd/`.

## Tech stack

| Tool | Role |
|------|------|
| Apache JMeter 5.6.x | Load and performance test execution |
| Java 11+ | JMeter runtime (OpenJDK / Temurin) |
| JSONPlaceholder | Public REST API for lab requests |
| PowerShell / Bash | CLI runs and scripting |
| GitHub Actions | Planned CI runs (Phase 5) |
| Python | Planned SLA validation scripts (Phase 5) |

## Project structure

```
jmeter-learning/
  scripts/
    phase1/                 Beginner: thread groups, HTTP, assertions, timers
    phase2/                 (planned) Correlation and parameterization
    phase3/                 (planned) Realistic scenarios and analysis
    phase4/                 (planned) Scripting and distributed testing
    phase5/                 (planned) CI/CD integration
  data/                     External CSV and test data (as labs add them)
  results/                  Raw .jtl output (gitignored)
  reports/                  Generated HTML dashboards (gitignored)
  ci-cd/                    (planned) Workflows and SLA scripts
```

## Learning phases

| Phase | Folder | Focus |
|-------|--------|--------|
| 1 | `scripts/phase1/` | Thread groups, HTTP defaults, assertions, think time |
| 2 | `scripts/phase2/` | Correlation, CSV parameterization, dynamic data |
| 3 | `scripts/phase3/` | Realistic user journeys, listeners, result analysis |
| 4 | `scripts/phase4/` | Groovy/JSR223, distributed and remote testing |
| 5 | `scripts/phase5/`, `ci-cd/` | Pipelines, SLA gates, automated reporting |

## Prerequisites

- [Apache JMeter 5.6+](https://jmeter.apache.org/download_jmeter.cgi) installed and on `PATH`, or run via `JMETER_HOME/bin`
- Java 11 or newer (`java -version`)
- Network access to jsonplaceholder.typicode.com

Optional: GUI for editing plans (`jmeter` or `jmeter.bat`); use non-GUI mode (`-n`) for real load runs.

## Running tests

Set `JMETER_HOME` if needed, then run from the repository root.

### Test runner (Windows)

Double-click or run from the repo root:

```bat
run-tests.bat
```

The script scans `scripts\` for `*.jmx` files that contain a **Thread Group**, lists them in a menu, and runs:

`jmeter -n -t <plan> -l results/<name>.jtl -e -o reports/<name>`

Choose a single lab by number, **A** to run all plans in order, or **Q** to quit. Tests are grouped by folder (`Phase 1:`, `Phase 2:`, …) and shown by file name only. New `.jmx` files under `scripts\` are picked up automatically on the next run.

The runner checks **`JMETER_HOME`**, `jmeter.bat`, `ApacheJMeter.jar`, and `java` as soon as it starts (before the menu). Set `JMETER_HOME` to your install folder, e.g. `C:\PerformanceTools\apache-jmeter-5.6.3`, and restart the terminal after changing environment variables.

### Non-GUI (recommended for load)

```bash
jmeter -n -t scripts/phase1/lab1_1.jmx -l results/lab1_1.jtl -e -o reports/lab1_1
```

PowerShell (same flags):

```powershell
jmeter -n -t scripts/phase1/lab1_1.jmx -l results/lab1_1.jtl -e -o reports/lab1_1
```

| Flag | Purpose |
|------|---------|
| `-n` | Non-GUI mode |
| `-t` | Test plan (`.jmx`) |
| `-l` | Results file (`.jtl`) |
| `-e` | Generate report dashboard after the run |
| `-o` | Output folder for HTML report (must be empty or omitted on first run) |

Open `reports/<run-name>/index.html` in a browser after the run.

### GUI (edit and debug)

```bash
jmeter -t scripts/phase1/lab1_1.jmx
```

Use the GUI for development only; disable or remove **View Results Tree** in heavy runs to save memory.

### Single lab examples

```bash
jmeter -n -t scripts/phase1/lab1_2.jmx -l results/lab1_2.jtl -e -o reports/lab1_2
jmeter -n -t scripts/phase1/lab1_3.jmx -l results/lab1_3.jtl -e -o reports/lab1_3
```

## License

Learning project -- use and modify freely.
