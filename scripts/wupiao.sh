#!/usr/bin/env bash
# [w]ait [u]ntil [p]ort [i]s [a]ctually [o]pen
# Usage: ./wupiao.sh server:host tries

set -e

[ -n "$1" ]
[ -n "$2" ]

function echo_red {
  echo -e "\033[0;31m$1\033[0m"
}

ATTEMPTS=$2
SLEEPTIME=1
COUNTER=1

until curl -o /dev/null -sIf http://${1}; do
  if [ $COUNTER -gt $ATTEMPTS ]; then
    echo_red "Timed out waiting for ${1}, giving up"
    exit 1
  fi
  sleep $SLEEPTIME
  let COUNTER=COUNTER+1
done;
