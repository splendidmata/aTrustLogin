#!/bin/bash

start-with-autologin-actual.sh &
start-port-forwarding.sh &

exec start.sh