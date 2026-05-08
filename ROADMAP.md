# Roadmap: Pi Skill Scanner

## Phase 1: MVP (Current Focus)
- [ ] Initialize repository structure (`SKILL.md`, `package.json`, `scripts/`).
- [ ] Create `scripts/build-env.sh` to generate the local Docker sandbox image.
- [ ] Create `scripts/scan-remote.sh` to clone a remote Git URL into the container and execute the deterministic static scan.
- [ ] Write `SKILL.md` frontmatter and instructions.
- [ ] Test the MVP locally by pointing it at a known `pi` skill repository.

## Phase 2: Local & Read-Only Scanning
- [ ] Add `scripts/scan-local.sh` to support scanning a directory already on the host machine.
- [ ] Implement secure Docker volume mounts (`-v /local/path:/target-repo:ro`) to ensure the scanner container cannot modify the host filesystem.

## Phase 3: Advanced Scanning (LLM Judge)
- [ ] Allow passing API credentials (e.g., `OPENAI_API_KEY`) into the Docker container.
- [ ] Enable the `cisco-ai-skill-scanner` LLM semantic analysis features to detect complex prompt injections and logic flaws.

## Phase 4: CI/CD & Reporting
- [ ] Add support for generating SARIF output.
- [ ] Format the output specifically for the `pi` agent so it can natively read the results and warn the user in the interactive UI.
