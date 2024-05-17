#!/bin/bash

# Configuration
idleDuration=$((60)) # 1 minute in seconds
shutdownDuration=$((3661)) # 1 hour 1 minute and 1 second in seconds
# appName="Trackabi Timer"

lock_screen() {
    osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
}

initialIdleTime=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000)}')

while true; done

    idleTime=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000)}')

    elapsedIdleTime=$((idleTime - initialIdleTime))

    if [ $elapsedIdleTime -ge $idleDuration ]; then
        lock_screen
        if [ $elapsedIdleTime -ge $shutdownDuration ]; then
            sudo shutdown -h now
            exit 0
        fi
    fi
    sleep 60
done
