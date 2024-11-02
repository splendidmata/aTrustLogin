#!/bin/sh

python3 /opt/atrust-autologin/main.py --interactive=True --wait_atrust=True $ATRUST_OPTS &

exec start.sh