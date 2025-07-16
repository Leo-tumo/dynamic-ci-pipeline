#!/bin/bash

set -e

IMAGE_NAME=${1:-"myapp:latest"}
SEVERITY=${2:-"HIGH,CRITICAL"}

echo "Scanning image: $IMAGE_NAME"
echo "Severity levels: $SEVERITY"

# Run Trivy scan
trivy image \
  --exit-code 1 \
  --severity "$SEVERITY" \
  --format table \
  --ignore-unfixed \
  "$IMAGE_NAME"

echo "Security scan completed successfully!"