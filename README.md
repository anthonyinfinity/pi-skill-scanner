# Pi Skill Scanner 🛡️

A security auditing skill for the `pi` coding agent. It allows you to pre-scan third-party `pi` skills and extensions for malicious patterns *before* installing them on your host machine.

## Why use this?
By default, `pi` packages run with full system access. Installing an untrusted skill or extension is extremely risky. 

This tool leverages the [Cisco AI Defense Skill Scanner](https://github.com/cisco-ai-defense/skill-scanner) to statically analyze a remote repository for prompt injections, data exfiltration, and malicious code. To guarantee safety during the scan, the untrusted code is cloned and analyzed entirely inside an ephemeral **Docker container sandbox**.

## Prerequisites
- [Docker](https://www.docker.com/) must be installed and running on your host machine.

## Installation

Install this skill directly via `pi` using the package manager:
```bash
pi install git:github.com/anthonyinfinity/pi-skill-scanner
```

## One-Time Setup

Before your first scan, you need to build the local Docker environment that isolates the scanner. 

Run this in your terminal:
```bash
~/.pi/agent/skills/pi-skill-scanner/scripts/build-env.sh
```
*(Note: If you install this project-locally instead of globally, adjust the path to `.pi/skills/pi-skill-scanner/...`)*

## Usage

Inside the `pi` interactive interface, you can audit any public GitHub repository URL by typing:

```text
/skill:audit-package https://github.com/username/untrusted-repo
```

`pi` will spin up the Docker sandbox, clone the repository safely inside it, run the deterministic security scan, and summarize any critical or high-severity findings for you in the chat.

## Important Disclaimer
> **No automated tool replaces human review.** This scanner is a best-effort defense-in-depth layer. A "clean" scan result does *not* guarantee that a skill is completely safe, benign, or free of novel vulnerabilities. You must manually review the source code of any script or extension before installing it, as they will execute with your host's user permissions.
## Security Architecture (The Sandbox)
To ensure that scanning malicious code doesn't accidentally infect your machine, this skill employs strict containment measures:
1. **Ephemeral Storage:** Repositories are cloned directly into Docker's ephemeral overlay filesystem. No untrusted files are ever written to your host Mac/PC. The filesystem is destroyed instantly when the scan finishes (`--rm`).
2. **Non-Root Execution:** The scanner runs as a low-privileged `scanneruser` inside the container.
3. **Kernel Sandboxing:** The container drops all Linux capabilities (`--cap-drop=ALL`) and blocks privilege escalation (`no-new-privileges`).
4. **Resource Limits:** The container is restricted to 1 CPU core and 1GB of RAM to prevent denial-of-service (DoS) attacks, such as "zip bombs" or infinite loops in malicious markdown files.
5. **Pinned Dependencies:** The skill scanner version is pinned to prevent supply chain attacks via the `latest` tag.

## Limitations
- **False Positives:** Static analysis tools flag behavioral patterns. If you scan a legitimate skill whose explicit purpose is web scraping or calling external APIs, the scanner will likely flag it as "Data Exfiltration". Apply context and human judgment to the results.
- **Public Repositories Only:** To maintain the security boundary, this tool currently only supports public git URLs so that SSH keys and personal access tokens do not need to be mounted into the sandbox.
- **Network Access:** The sandbox requires outbound network access to perform the `git clone`. For maximum security, do not mount any local AWS/GCP credentials or API keys into this environment.
