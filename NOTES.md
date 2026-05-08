# Pi Skill Scanner - Ideation & Notes

## Mindset: MVP & Focus
We are strictly adhering to a Minimum Viable Product (MVP) approach to avoid scope creep. The primary objective is to get a functional, secure, and reliable baseline working before adding advanced features.

## Goal (MVP)
Create a `pi` skill that performs a static, deterministic security scan on remote Git repositories containing third-party `pi` skills/extensions. The scan must happen inside an isolated Docker sandbox.

## Architecture (Modular Design)
To ensure we can easily add features (like local scanning or LLM integration) later, we will separate concerns:
1.  **`SKILL.md`**: Only contains documentation, setup instructions, and the `/skill` command mapping.
2.  **`scripts/build-env.sh`**: Responsible purely for building the local Docker image (`pi-skill-scanner-env`).
3.  **`scripts/scan-remote.sh`**: Takes a Git URL, spins up the container, runs the deterministic scan, and cleans up. 

By keeping `scan-remote.sh` separate, we can easily add a `scan-local.sh` later without complicating the remote repository logic.

## The MVP Docker Sandbox
- **Base Image:** `python:3.10-slim`
- **Dependencies:** `git`, `cisco-ai-skill-scanner`
- **Execution:** 
  - Clone target repo into `/target-repo` inside the container.
  - Run `skill-scanner --lenient /target-repo`.
  - Destroy container (`--rm`).
  - *Note: No API keys are passed in MVP. The scanner will run its deterministic static/YARA rules, which is already a massive improvement over no scanning.*

## Working Directory
`~/repos/pi-skill-scanner`

## Definition of Done (MVP)
- All required files (`SKILL.md`, `build-env.sh`, `scan-remote.sh`) are implemented.
- The Docker image builds successfully without errors.
- The `scan-remote.sh` script successfully clones a public repository and runs `skill-scanner`, outputting the results.
- The skill correctly registers in `pi` as a `/skill` command.
- The host system remains completely isolated from the cloned repository.

## Definition of Success
- A developer can type `/skill:audit-package https://github.com/some/repo` in `pi`, and `pi` reads the scan output to confidently advise whether the skill contains known malicious patterns.
- The process is fast enough (under 30 seconds) that developers actually *want* to use it before installing new extensions.
- Zero false negatives for basic deterministic threats (e.g., hardcoded data exfiltration URLs, known prompt injection signatures) that the Cisco scanner's static engine supports.

## Developer Experience (DX)
- **Setup:** A one-time `/skill:audit-setup` (or manual `./scripts/build-env.sh`) that takes ~1 minute to build the Docker image. 
- **Invocation:** Seamless invocation from within the `pi` chat interface. 
- **Feedback:** The output of the bash script should be concise enough that the `pi` agent can read it and say, *"The scan found 2 high-severity issues related to data exfiltration. I recommend NOT installing this."* rather than just dumping raw JSON.

## Considerations & Constraints
- **Docker Requirement:** The user *must* have Docker installed and the Docker daemon running. The script should elegantly fail and notify the user if Docker is missing.
- **Public vs. Private Repos:** For the MVP, we will only support **public** repositories. Handling SSH keys or personal access tokens inside the Docker container adds too much complexity for Phase 1.
- **Context Window:** The scanner's output must fit within the `pi` agent's context window. We should ensure we don't dump massive debug logs.
