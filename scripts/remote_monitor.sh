#!/bin/bash
# remote_monitor.sh - Runs the audit on a remote machine via SSH and retrieves the report

# Configuration
REMOTE_USER="user"              # SSH username on the remote machine
REMOTE_HOST="192.168.1.100"     # IP of the remote machine
REMOTE_SCRIPT="/tmp/hardware_audit.sh"
LOCAL_SAVE_DIR="./reports"

# Copy the hardware audit script to the remote machine and run it
monitor_remote() {
    echo "Connecting to $REMOTE_USER@$REMOTE_HOST ..."

    # Copy script to remote
    scp "$(dirname "$0")/hardware_audit.sh" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_SCRIPT}"
    if [ $? -ne 0 ]; then
        echo "Error: could not copy script to remote machine"
        exit 1
    fi

    # Run it remotely and save output locally
    mkdir -p "$LOCAL_SAVE_DIR"
    OUTFILE="${LOCAL_SAVE_DIR}/remote_${REMOTE_HOST}_$(date +%Y%m%d_%H%M%S).txt"

    ssh "${REMOTE_USER}@${REMOTE_HOST}" "bash ${REMOTE_SCRIPT}" > "$OUTFILE"

    if [ $? -eq 0 ]; then
        echo "Remote audit completed. Report saved to: $OUTFILE"
    else
        echo "Error: SSH command failed"
        exit 1
    fi

    # Clean up remote script
    ssh "${REMOTE_USER}@${REMOTE_HOST}" "rm -f ${REMOTE_SCRIPT}"
}

monitor_remote
