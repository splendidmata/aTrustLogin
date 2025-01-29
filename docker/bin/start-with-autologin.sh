#!/bin/bash

echo "Starting aTrustLogin Docker Image ..."
echo "Built at $(cat /etc/build-date.txt)"

start-with-autologin-actual.sh &
start-port-forwarding.sh &

exec start.sh