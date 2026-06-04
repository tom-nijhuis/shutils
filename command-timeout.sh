#!/bin/bash

# Configuration
TIMEOUT_SECONDS=$2 #
COMMAND_TO_RUN=$1

# Lock file for this command (based on sha256)
LOCK_FILE="/tmp/timeout/$(echo $COMMAND_TO_RUN | sha256sum | awk '{print substr($1, 58)}')"

# Get current time and last run time
CURRENT_TIME=$(date +%s)
# If file doesn't exist, set LAST_RUN to 0 so the math always triggers the command
LAST_RUN=$(date -r "$LOCK_FILE" +%s 2>/dev/null || echo 0)
ELAPSED=$((CURRENT_TIME - LAST_RUN))

# Trigger if ELAPSED >= TIMEOUT_SECONDS or lock file missing
if [ "$ELAPSED" -ge "$TIMEOUT_SECONDS" ] || [ ! -f "$LOCK_FILE" ]; then
  # run the command (use eval only if COMMAND_TO_RUN contains complex shell syntax)
  $COMMAND_TO_RUN

  # compute next run time (GNU date). (Portable across macos and GNU)
  next_epoch=$(($CURRENT_TIME + TIMEOUT_SECONDS))
  if date --version >/dev/null 2>&1; then
    # GNU date (Linux)
    NEXT_RUN_AT=$(date -d "@$next_epoch" '+%Y-%m-%d %H:%M:%S')
  else
    # BSD date (macOS)
    NEXT_RUN_AT=$(date -r "$next_epoch" '+%Y-%m-%d %H:%M:%S')
  fi

  mkdir -p /tmp/timeout
  {
    printf 'Command: %s\n' "$COMMAND_TO_RUN"
    printf 'Timeout (s): %s\n' "$TIMEOUT_SECONDS"
    printf 'Locked until: %s\n' "$NEXT_RUN_AT"
  } >"$LOCK_FILE"

else
  # in lock-out. Report remaining seconds
  REMAINING=$((TIMEOUT_SECONDS - ELAPSED))
  echo "Locked. Wait ${REMAINING}s."
fi
