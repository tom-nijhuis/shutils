#!/bin/bash

# Configuration
TIMEOUT_SECONDS=$2
COMMAND_TO_RUN=$1

# Hash the command — shasum (macOS BSD)
HASH=$(printf '%s' "$COMMAND_TO_RUN" | shasum -a 256 | awk '{print substr($1, 58)}')
LOCK_FILE="/tmp/timeout/$HASH"

# Get current time and last run time.
# The lock file is deleted and recreated on each run, so mtime == creation time.
CURRENT_TIME=$(date +%s)
LAST_RUN=$(date -r "$LOCK_FILE" +%s 2>/dev/null || echo 0)
ELAPSED=$((CURRENT_TIME - LAST_RUN))

# Trigger if ELAPSED >= TIMEOUT_SECONDS or lock file missing
if [ "$ELAPSED" -ge "$TIMEOUT_SECONDS" ] || [ ! -f "$LOCK_FILE" ]; then
  $COMMAND_TO_RUN

  # compute time in human readable form (GNU date). (Portable across macOS and GNU)
  if date --version >/dev/null 2>&1; then
    CURRENT_TIME_HR=$(date -d "@$CURRENT_TIME" '+%Y-%m-%d %H:%M:%S')
    NEXT_RUN_HR=$(date -d "@$((CURRENT_TIME + TIMEOUT_SECONDS))" '+%Y-%m-%d %H:%M:%S')
  else
    CURRENT_TIME_HR=$(date -r "$CURRENT_TIME" '+%Y-%m-%d %H:%M:%S')
    NEXT_RUN_HR=$(date -r "$((CURRENT_TIME + TIMEOUT_SECONDS))" '+%Y-%m-%d %H:%M:%S')
  fi

  mkdir -p /tmp/timeout
  rm -f "$LOCK_FILE"
  {
    printf 'Command     : %s\n' "$COMMAND_TO_RUN"
    printf 'Timeout (s) : %s\n' "$TIMEOUT_SECONDS"
    printf 'Last run    : %s\n' "$CURRENT_TIME_HR"
    printf 'Locked until: %s\n' "$NEXT_RUN_HR"
  } >"$LOCK_FILE"
else
  REMAINING=$((TIMEOUT_SECONDS - ELAPSED))
  echo "Locked. Wait ${REMAINING}s."
fi
