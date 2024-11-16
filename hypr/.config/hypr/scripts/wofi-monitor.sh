#!/bin/bash

LOG_FILE="$HOME/.cache/wofi-monitor.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Clear log file
echo "" > "$LOG_FILE"

log "Starting wofi monitor script"

# Log Hyprland environment variables
log "Environment variables:"
log "HYPRLAND_INSTANCE_SIGNATURE=$HYPRLAND_INSTANCE_SIGNATURE"
log "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"

# Check if we're actually running in Hyprland
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    log "ERROR: Not running in Hyprland or HYPRLAND_INSTANCE_SIGNATURE is not set!"
    log "Current environment:"
    env >> "$LOG_FILE"
    exit 1
fi

# Use the correct socket path
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Check if socket exists
if [ ! -S "$SOCKET" ]; then
    log "ERROR: Socket $SOCKET does not exist or is not a socket!"
    log "Available files in $(dirname "$SOCKET"):"
    ls -la "$(dirname "$SOCKET")" >> "$LOG_FILE" 2>&1
    exit 1
fi

log "Found socket: $SOCKET"
log "Attempting to connect..."

# Try to connect and log the result
socat -U - "UNIX-CONNECT:$SOCKET" | while read -r line; do
    log "Received event: $line"
    if [[ $line == *"activewindow>>"* ]]; then
        log "Focus change detected"
        if [[ ! $line == *"wofi"* ]]; then
            log "Focus changed to non-wofi window, killing wofi"
            pkill wofi
            log "pkill wofi executed"
        else
            log "Focus is on wofi, not killing"
        fi
    fi
done

# If we get here, socat disconnected
log "Socat connection ended"

