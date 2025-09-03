#!/bin/zsh
set -euo pipefail

TASKS_FILE="$HOME/tasks.csv"

if [[ $# -lt 2 ]]; then
  echo "Usage: ./note JOB_TYPE NOTE..."
  echo "Example: ./note WEEKLY Have fun with friends"
  exit 1
fi

CACHE_FILE="/tmp/tasks-cache-$(date +%Y-%m-%d)"
rm -f $CACHE_FILE

JOB_TYPE="$1"
shift
NOTE="$*"

DATE=$(date +%Y-%m-%d)

# If file doesn’t exist, create header
if [[ ! -f "$TASKS_FILE" ]]; then
  echo "JOB_TYPE,DATE,NOTE" > "$TASKS_FILE"
fi

# Insert new row after header (so newest at top)
TMP_FILE=$(mktemp)
{
  head -n1 "$TASKS_FILE"
  echo "$JOB_TYPE,$DATE,\"$NOTE\""
  tail -n +2 "$TASKS_FILE"
} > "$TMP_FILE"

mv "$TMP_FILE" "$TASKS_FILE"

unset _JOBS_CACHE

