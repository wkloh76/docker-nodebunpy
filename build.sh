#!/bin/bash
# Build x64 image
set -a
source .env
set +a
docker build -f Dockerfile \
  --build-arg NODE_VERSION="${TAG}" \
  --build-arg BUN_VERSION="${ARG1}" \
  -t "${IMG}:${TAG}-${ARG1}" .
