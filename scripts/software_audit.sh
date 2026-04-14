#!/bin/bash
# software_audit.sh - Collects OS and software information

collect_software_info() {
    echo "===== SOFTWARE & OS AUDIT ====="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo ""

    echo "--- OS INFO ---"
    cat /etc/os-release 2>/dev/null | grep -E "PRETTY_NAME|VERSION"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo ""

    echo "--- INSTALLED PACKAGES ---"
    if command -v dpkg &>/dev/null; then
        echo "Total packages: $(dpkg -l | grep '^ii' | wc -l)"
        echo "Last 10 installed:"
        dpkg -l | grep '^ii' | tail -10 | awk '{print $2, $3}'
    elif command -v rpm &>/dev/null; then
        echo "Total packages: $(rpm -qa | wc -l)"
        rpm -qa | tail -10
    else
        echo "Package manager not identified"
    fi
    echo ""

    echo "--- LOGGED IN USERS ---"
    who
    echo ""

    echo "--- RUNNING SERVICES ---"
    if command -v systemctl &>/dev/null; then
        systemctl list-units --type=service --state=running 2>/dev/null | head -20
    else
        service --status-all 2>/dev/null | grep "+" | head -20 || echo "systemctl not available"
    fi
    echo ""

    echo "--- ACTIVE PROCESSES (top 15 by CPU) ---"
    ps aux --sort=-%cpu | head -16
    echo ""

    echo "--- OPEN PORTS ---"
    if command -v ss &>/dev/null; then
        ss -tuln 2>/dev/null | head -20
    elif command -v netstat &>/dev/null; then
        netstat -tuln 2>/dev/null | head -20
    else
        echo "ss/netstat not available"
    fi
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    collect_software_info
fi
