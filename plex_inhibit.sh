#!/bin/sh
#
CHECK_INTERVAL=30
LOCK_FILE="/run/plex_inhibit/lock"


log_message() {
  printf "$1\n"
}

check_plex_traffic() {
  netstat -tunap 2>/dev/null | 
    grep ":32400 " | 
      grep -q -E "ESTABLISHED|RELATED" 
  return "$?"
}

inhibit_loop() {
  log_message \
    "Inhibiting idle (Plex traffic detected)"

  while check_plex_traffic
  do
    sleep "$CHECK_INTERVAL"
  done

  log_message \
    "Releasing idle inhibit (no Plex traffic), PID: $PID"
}

main_loop() {
  log_message "$0 start"
  while true
  do
    if check_plex_traffic
    then
      systemd-inhibit \
	--what=idle \
	--who="Plex" \
	--why="Plex activity" \
	"$0" inhibit
    else
      sleep "$CHECK_INTERVAL"
    fi
  done
}

if test "$FLOCKER" != "$0"
  then
    env FLOCKER="$0" flock -en "$0" "$0" "$@" ||
      log_message \
	"Another instance of $0 is already running. Exiting."
  else
    if test "$1" = "inhibit"
      then
	inhibit_loop
      else
	main_loop
      fi
  fi
