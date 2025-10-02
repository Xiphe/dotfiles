# Sleep Hook Daemon

A minimal macOS daemon that triggers actions when the system is about to go to sleep.

## Files

- `sleephook.swift` - Swift daemon source code
- `com.sleephook.plist` - LaunchAgent configuration
- `sleep.sh` - Simple wrapper script called by the daemon

## Setup

### 1. Compile the Daemon

```bash
swiftc sleephook.swift -o sleephook
chmod +x sleephook
```

### 2. Install the LaunchAgent

```bash
# Copy plist to LaunchAgents directory
cp com.sleephook.plist ~/Library/LaunchAgents/

# Load the daemon
launchctl load ~/Library/LaunchAgents/com.sleephook.plist
```

### 3. Verify Installation

```bash
# Check if daemon is running
pgrep -f sleephook

# Check daemon logs
tail -f /tmp/sleephook.out /tmp/sleephook.err
```

## Uninstall

```bash
# Unload the daemon
launchctl unload ~/Library/LaunchAgents/com.sleephook.plist

# Remove files
rm ~/Library/LaunchAgents/com.sleephook.plist
rm ~/dotfiles/sleep/sleephook
```

## How It Works

The Swift daemon registers for `NSWorkspace.willSleepNotification` and executes `sleep.sh` when macOS is about to sleep. The daemon runs continuously in the background via LaunchAgent.

## Requirements

- macOS with Xcode command line tools
- Swift compiler (`swiftc`)
