#!/bin/bash


REMOTE_USER="rachid"              
REMOTE_HOST="10.224.97.173"     
REMOTE_SCRIPT_1="/tmp/software_audit.sh"
REMOTE_SCRIPT_2="/tmp/hardware_audit.sh"
LOCAL_SAVE_DIR="./reports"


monitor_remote() {
    echo "Connecting to $REMOTE_USER@$REMOTE_HOST ..."

    
    scp -P 1645 "$(dirname "$0")/software_audit.sh" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_SCRIPT_1}"
    scp -P 1645 "$(dirname "$0")/hardware_audit.sh" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_SCRIPT_2}"

    if [ $? -ne 0 ]; then
        echo "Error: could not copy script to remote machine"
        exit 1
    fi

    
    mkdir -p "$LOCAL_SAVE_DIR"
    OUTFILE="${LOCAL_SAVE_DIR}/remote_${REMOTE_HOST}_$(date +%Y%m%d_%H%M%S).txt"

    ssh -p 1645 "${REMOTE_USER}@${REMOTE_HOST}" "bash ${REMOTE_SCRIPT_1} full" > "$OUTFILE"
    ssh -p 1645 "${REMOTE_USER}@${REMOTE_HOST}" "bash ${REMOTE_SCRIPT_2} full" >> "$OUTFILE"

    if [ $? -eq 0 ]; then
        echo "Remote audit completed. Report saved to: $OUTFILE"
    else
        echo "Error: SSH command failed"
        exit 1
    fi

    
    ssh -p 1645 "${REMOTE_USER}@${REMOTE_HOST}" "rm -f ${REMOTE_SCRIPT_1}"
    ssh -p 1645 "${REMOTE_USER}@${REMOTE_HOST}" "rm -f ${REMOTE_SCRIPT_2}"

}

monitor_remote
