#!/bin/sh

CHECK_INTERVAL=60
INHIBIT_IDENTIFIER="Plex Traffic"
INHIBIT_PID=""
LOCK_FILE="/run/plex_inhibit/lock"
GOT_LOCK=0
LOCK_FD=3  # Use a fixed file descriptor number >= 3

log_message() {
  printf "%s - %s\n" "$(date)" "$1"
}

clean_up() {
  if [ "$GOT_LOCK" -eq 1 ]; then
    flock -u "$LOCK_FD" # Using the variable here is okay for flock
    log_message "Released lock on $LOCK_FILE"
  fi

  exec 3<&-          # Close file descriptor 3

  if [ -n "$INHIBIT_PID" ]; then
    kill "$INHIBIT_PID" >/dev/null 2>&1
  fi

  exit
}

trap clean_up EXIT HUP INT QUIT TERM

check_plex_traffic() {
  netstat -tunap 2>/dev/null | 
    grep ":32400 " | 
      grep -q -E "ESTABLISHED|RELATED" 
  return "$?"
}

start_inhibit() {
  if [ -z "$INHIBIT_PID" ] || 
    ! kill -0 "$INHIBIT_PID" > /dev/null 2>&1; then

    systemd-inhibit \
      --what=idle \
      --who="$INHIBIT_IDENTIFIER" \
      --why="Plex is actively streaming." \
      sleep infinity &

    INHIBIT_PID="$!"
    log_message \
      "Inhibiting idle (Plex traffic detected), PID: $INHIBIT_PID"
  fi
}

stop_inhibit() {
  if [ -n "$INHIBIT_PID" ] &&
    kill "$INHIBIT_PID" > /dev/null 2>&1; then
    log_message \
      "Releasing idle inhibit (no Plex traffic), PID: $PID"
    INHIBIT_PID=""
  fi
}

main_loop() {
  while true; do
    if check_plex_traffic; then
      start_inhibit
    else
      stop_inhibit
    fi
    sleep "$CHECK_INTERVAL"
  done
}

# Ensure the lock file exists and is open on FD 3
touch "$LOCK_FILE"
exec 3<>"$LOCK_FILE" # Open for reading and writing on FD 3

# Attempt to acquire the lock
if flock -n 3; then
  GOT_LOCK=1
  main_loop
else
  log_message \
    "Another instance of plex_inhibit.sh is already running. Exiting."
  exec 3<&- # Close FD 3 if we didn't get the lock
  exit 1
fi

# Clean up lock (though trap should handle this)
clean_up
