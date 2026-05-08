---
name: audit-package
description: Scans a remote Git repository for security threats (prompt injections, data exfiltration) before installing it as a pi skill or extension.
---

# Pi Skill Scanner

This skill uses the [Cisco AI Defense Skill Scanner](https://github.com/cisco-ai-defense/skill-scanner) running inside a Docker sandbox to evaluate third-party `pi` packages before you install them on your host machine.

## Prerequisites

- Docker must be installed and running.

## Setup

Before first use, you must build the local Docker sandbox image. 

Run this command:
```bash
./scripts/build-env.sh
```

## Usage

Provide the URL of the public Git repository you want to scan.

```bash
./scripts/scan-remote.sh <repository-url>
```

### Example for the AI Agent:

If the user asks: "Can you check if `https://github.com/some-user/untrusted-skill` is safe?", you should run:

```bash
./scripts/scan-remote.sh https://github.com/some-user/untrusted-skill
```

Then, read the output and summarize the findings for the user. Pay special attention to any critical or high-severity issues reported by the scanner.
