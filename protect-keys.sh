#!/usr/bin/env bash

set -euo pipefail

MOUNTPOINT="/Volumes/Keys"
BUNDLE="$HOME/Keys.sparsebundle"        
DEST="$HOME/pCloud Drive/Archiv/Local/Keys.sparsebundle"
LOG_FILE="/tmp/protect-keys.log"

# Handle --check-log flag
if [ "${1:-}" = "--check-log" ]; then
    # Truncate log to 200 lines if it's longer
    if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt 200 ]; then
        tail -n 200 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi

        # Check daemon status
        if ! pgrep -f "sleephook" > /dev/null; then
            echo "❌ Sleephook daemon not running"
        fi

        # Check keys volume status  
        if ! mount | grep -q "$MOUNTPOINT"; then
            echo "❌ Keys volume not mounted"
        fi

        # Check for recent errors/warnings
        if [ -f "$LOG_FILE" ]; then
            RECENT_ERRORS=$(tail -n 4 "$LOG_FILE" | grep -E "ERROR|WARNING")
            if [ -n "$RECENT_ERRORS" ]; then
                echo "❌ Recent protect-keys errors:"
                echo "$RECENT_ERRORS" | sed 's/^/  /'
            fi
        fi
        exit 0
fi

# Function to log with timestamp
log() {
    echo "[$(date -Iseconds)] [protect-keys] $1" >> "$LOG_FILE"
}

# Check 1: BUNDLE must be present
if [ ! -d "$BUNDLE" ]; then
    log "ERROR: BUNDLE not found at $BUNDLE"
    exit 1
fi

# Check 2: MOUNTPOINT may or may not be present
if [ ! -d "$MOUNTPOINT" ]; then
    log "INFO: MOUNTPOINT not present at $MOUNTPOINT - aborting"
    exit 0
fi

# Check 3: DEST should be present, warn if not
if [ ! -d "$(dirname "$DEST")" ]; then
    log "WARNING: DEST directory doesn't exist at $(dirname "$DEST") - aborting"
    exit 0
fi

# All checks passed - proceed with operations
log "Starting sync operations"

# 1. Kill any GPG processes that might interfere
log "Terminating all GPG processes before unmount"
gpgconf --kill all || log "WARNING: Failed to terminate GPG processes"

# 2. Unmount volume
if mount | grep -q "$MOUNTPOINT"; then
    log "Unmounting $MOUNTPOINT"
    diskutil unmount "$MOUNTPOINT" || {
        log "ERROR: Failed to unmount $MOUNTPOINT"
        exit 1
    }
fi

# 3. Copy/sync BUNDLE to DEST
log "Syncing $BUNDLE to $DEST"
rsync -av --delete "$BUNDLE" "$(dirname "$DEST")/" || {
    log "ERROR: Failed to sync $BUNDLE to $DEST"
    exit 1
}

# 4. Log success
log "SUCCESS: closed and synced keys"