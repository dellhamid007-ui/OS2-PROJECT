#!/bin/bash
# send_report.sh - Sends a report file via email using msmtp or mail

# Configuration
RECIPIENT="dell.hamid007@gmail.com"   # Change this
SUBJECT="System Audit Report - $(hostname) - $(date +%Y-%m-%d)"

send_email() {
    local REPORT_FILE="$1"

    if [ -z "$REPORT_FILE" ] || [ ! -f "$REPORT_FILE" ]; then
        echo "Error: report file not found: $REPORT_FILE"
        exit 1
    fi

    if command -v msmtp &>/dev/null; then
        echo "Sending via msmtp..."
        # msmtp is only an SMTP relay, it does not accept --subject flags.
        # We build the email headers ourselves and pipe the whole thing in.
        {
            echo "To: $RECIPIENT"
            echo "Subject: $SUBJECT"
            echo ""
            cat "$REPORT_FILE"
        } | msmtp "$RECIPIENT"

    elif command -v mail &>/dev/null; then
        echo "Sending via mail..."
        mail -s "$SUBJECT" "$RECIPIENT" < "$REPORT_FILE"

    else
        echo "Error: no mail utility found (install msmtp or mailutils)"
        exit 1
    fi

    if [ $? -eq 0 ]; then
        echo "Email sent to $RECIPIENT"
    else
        echo "Failed to send email"
    fi
}

# Usage: ./send_report.sh /path/to/report.txt
send_email "$1"
