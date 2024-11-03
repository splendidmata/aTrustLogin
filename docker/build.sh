#!/usr/bin/env bash

cd "$(dirname "$0")/.."
echo "Pulling base docker image..."
docker pull hagb/docker-atrust:latest
echo "Building docker image..."
docker build -t kenvix/atrust-autologin:latest .