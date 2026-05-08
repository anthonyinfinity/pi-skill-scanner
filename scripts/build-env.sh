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

# Install the Cisco AI Defense Skill Scanner
RUN pip install --no-cache-dir cisco-ai-skill-scanner

# Set a working directory
WORKDIR /workspace
EOF

echo "Build complete! The local image '$IMAGE_NAME' is ready."
