#!/bin/bash
# report_gen.sh - Generates short and full reports as .txt files

REPORT_DIR="/var/log/sys_audit"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HOSTNAME=$(hostname)

source "$(dirname "$0")/hardware_audit.sh"
source "$(dirname "$0")/software_audit.sh"

# Create report directory, fall back to ./reports if no permission
setup_dir() {
    mkdir -p "$REPORT_DIR" 2>/dev/null
    if [ ! -w "$REPORT_DIR" ]; then
        REPORT_DIR="$(dirname "$0")/../reports"
        mkdir -p "$REPORT_DIR"
    fi
}

generate_short_report() {
    setup_dir
    OUTFILE="${REPORT_DIR}/short_report_${HOSTNAME}_${TIMESTAMP}.txt"

    {
        echo "============================================"
        echo "       SYSTEM AUDIT - SHORT REPORT"
        echo "============================================"
        echo "Date     : $(date)"
        echo "Hostname : $HOSTNAME"
        echo "============================================"
        echo ""

        echo "--- OS ---"
        cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"'
        echo "Kernel: $(uname -r)"
        echo ""

        echo "--- CPU ---"
        lscpu | grep "Model name" | cut -d: -f2 | xargs
        echo "Cores: $(nproc)"
        echo ""

        echo "--- RAM ---"
        free -h | grep Mem | awk '{print "Total: "$2, "| Used: "$3, "| Free: "$4}'
        echo ""

        echo "--- DISK (summary) ---"
        df -h --total 2>/dev/null | grep total || df -h | tail -1
        echo ""

        echo "--- NETWORK ---"
        hostname -I 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -5
        echo ""

        echo "--- USERS LOGGED IN ---"
        who | awk '{print $1}' | sort -u
        echo ""

        echo "============================================"
        echo "   END OF SHORT REPORT"
        echo "============================================"
    } > "$OUTFILE"

    echo "Short report saved to: $OUTFILE"
}

generate_full_report() {
    setup_dir
    OUTFILE="${REPORT_DIR}/full_report_${HOSTNAME}_${TIMESTAMP}.txt"

    {
        echo "============================================"
        echo "       SYSTEM AUDIT - FULL REPORT"
        echo "============================================"
        echo "Date     : $(date)"
        echo "Hostname : $HOSTNAME"
        echo "============================================"
        echo ""
        collect_hardware_info
        echo ""
        collect_software_info
        echo ""
        echo "============================================"
        echo "   END OF FULL REPORT"
        echo "============================================"
    } > "$OUTFILE"

    echo "Full report saved to: $OUTFILE"
}

# Main: accept argument
case "$1" in
    short) generate_short_report ;;
    full)  generate_full_report ;;
    *)
        echo "Usage: $0 {short|full}"
        exit 1
        ;;
esac
