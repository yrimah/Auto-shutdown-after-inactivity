#!/bin/bash

# place the script in this location : /usr/bin/script.bash

idleDuration=$(60) # 1min

appName="Trackabi Timer"

# Get the initial user idle time
initialIdleTime=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000)}')

while true; do
    # Get the current user idle time
    idleTime=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000)}')

    # Calculate the elapsed idle time
    elapsedIdleTime=$((idleTime - initialIdleTime))

    # Check if the elapsed idle time exceeds the specified duration
    if [ $elapsedIdleTime -ge $idleDuration ]; then
        # Stop the specified application if it is running
        if pgrep -x "$appName" > /dev/null; then
            pkill -x "$appName"
        fi

        sudo shutdown -P now
        exit 0
    fi

    sleep 60
done

## chmod +x script.bash : to give users the permission to execute the script ##