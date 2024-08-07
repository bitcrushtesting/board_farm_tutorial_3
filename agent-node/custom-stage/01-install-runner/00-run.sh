#!/bin/bash -e

# Define the GitHub Runner version you want to install
GITHUB_RUNNER_VERSION="2.317.0"

# Create a directory for the GitHub runner
mkdir -p "${ROOTFS_DIR}/opt/bin/actions-runner"
cd "${ROOTFS_DIR}/opt/bin/actions-runner"

# Download the runner package
curl -o actions-runner-linux-arm64-$GITHUB_RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$GITHUB_RUNNER_VERSION/actions-runner-linux-arm64-$GITHUB_RUNNER_VERSION.tar.gz

# Extract the runner package
tar xzf ./actions-runner-linux-arm64-$GITHUB_RUNNER_VERSION.tar.gz
rm ./actions-runner-linux-arm64-$GITHUB_RUNNER_VERSION.tar.gz

