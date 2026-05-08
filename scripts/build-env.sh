#!/bin/bash
set -e

IMAGE_NAME="pi-skill-scanner-env"

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker does not appear to be running. Please start Docker and try again."
  exit 1
fi

echo "Building Docker image: $IMAGE_NAME..."

docker build -t "$IMAGE_NAME" - <<EOF
FROM python:3.10-slim

# Install git (required for cloning the target repo)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Create a non-root user for executing the scans safely
RUN useradd -m -s /bin/bash scanneruser

# Install the Cisco AI Defense Skill Scanner and pin the exact version 
# to prevent automated supply chain attacks via the 'latest' tag.
RUN pip install --no-cache-dir cisco-ai-skill-scanner==2.0.11

# Set a working directory and give the non-root user ownership
WORKDIR /workspace
RUN chown scanneruser:scanneruser /workspace

# Switch to the non-root user so the container doesn't run as root
USER scanneruser
EOF

echo "Build complete! The local image '$IMAGE_NAME' is ready."
