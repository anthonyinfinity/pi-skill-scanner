#!/bin/bash

IMAGE_NAME="pi-skill-scanner-env"
TARGET_URL="$1"
OUTPUT_REPORT="$2"

# Basic validation
if [ -z "$TARGET_URL" ]; then
  echo "Error: Please provide a git repository URL."
  echo "Usage: ./scan-remote.sh <repository-url> [optional: --report]"
  exit 1
fi

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker does not appear to be running."
  exit 1
fi

# Check if the image exists
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
  echo "Error: Docker image '$IMAGE_NAME' not found."
  echo "Please run './scripts/build-env.sh' first."
  exit 1
fi

echo "Spinning up sandbox to scan: $TARGET_URL"

# Run the container. 
# - We clone the repo inside the container.
# - We run the scanner with --lenient to handle various markdown structures.
# - The container is destroyed (--rm) immediately after.
docker run --rm -i "$IMAGE_NAME" /bin/bash -c "
  echo 'Cloning repository...'
  git clone --depth 1 $TARGET_URL /target-repo > /dev/null 2>&1
  
  if [ \$? -ne 0 ]; then
    echo 'Error: Failed to clone repository. Ensure it is a valid, public Git URL.'
    exit 1
  fi
  
  if [ \"$OUTPUT_REPORT\" == \"--report\" ]; then
    echo 'Running cisco-ai-skill-scanner and generating report...'
    skill-scanner scan --lenient -o json /target-repo > /dev/null 2>&1
    cat scan-report.json
  else
    echo 'Running cisco-ai-skill-scanner...'
    skill-scanner scan --lenient /target-repo
  fi
"
