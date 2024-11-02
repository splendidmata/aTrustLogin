#!/usr/bin/env bash

cd "$(dirname "$0")/.."
docker pull kenvix/atrust-autologin:latest
docker build -t kenvix/atrust-autologin:latest .