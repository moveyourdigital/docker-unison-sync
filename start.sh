#!/usr/bin/env bash
set -e

trap printout SIGINT

printout() {
  echo "Exiting..."
  exit 0
}

waitforit() {
  exec /wait-for-it.sh $REMOTE:$PORT
}

server() {
  echo "Starting in server mode..."
  unison -socket $PORT &
  wait $!
}

client() {
  if [ -z "$REMOTE" ]; then
    echo "Error: no destination. Set REMOTE with a valid destination" >&2
    exit 1
  fi

  if ! [[ "$INTERVAL" =~ ^-?[0-9]+$ ]]; then
    echo "Error: INTERVAL must be numeric" >&2
    exit 1
  fi

  waitforit &
  wait $!

  echo "Starting synchronization"
  echo " Source: $SOURCE"
  echo " Remote: socket://$REMOTE:$PORT/$SOURCE"
  echo " Interval: $INTERVAL seconds"

  while :; do
    unison $SOURCE socket://$REMOTE:$PORT/$SOURCE
    sleep $INTERVAL &
    wait $!
  done
}

case "$MODE" in
  server) server ;;
  client) client ;;
  *) echo "Error: invalid mode. Set MODE to 'client' or 'server'" >&2
     exit 1 ;;
esac
