#!/bin/sh
#
# Toggles a wemo switch based on microsnitch's log
# Requires ouimeaux (install with `pip install ouimeaux`)
#

# Configuration
# Micro Snitch log location
LOG="$HOME/Library/Logs/Micro Snitch.log"
# Name of the Camera event you'd like to listen for
CAMERA="FaceTime HD Camera (Display)"
# The wemo switch to toggle
SWITCH="Zoom lights"
# How frequently to check the log (default: 5s)
POLL_TIME=5


if [[ ! -f $LOG ]]; then
    echo >&2 "Error: No Micro Snitch log found in $LOG."
    exit 1
fi

command -v wemo >/dev/null 2>&1 || {
    echo >&2 "Error: wemo command not found. Try installing ouimeaux, with 'pip install ouimeaux'.  Aborting."
    exit 1
}

function toggle_switch(){
    local action=$1
    local switch_status=$(wemo switch "$SWITCH" status)
    if [[ "$switch_status" = "0" && $1 = "on" ]]; then
        wemo switch "$SWITCH" on
    fi

    if [[ "$switch_status" = "1" && $1 = "off" ]]; then
        wemo switch "$SWITCH" off
    fi
}


while true
do
    status=$(awk 'END{o=$10; for (i=11; i<=NF; i++) {o=o" "$i}; print o}' "$LOG")
    if [[ "$status" = "active: $CAMERA" ]]; then
      toggle_switch on
    fi
    if [[ "$status" = "inactive: $CAMERA" ]]; then
       toggle_switch off
    fi
    sleep $POLL_TIME
done
