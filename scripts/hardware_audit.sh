#!/bin/bash
# hardware_audit.sh - Collects hardware information

collect_hardware_info() {
    echo "===== HARDWARE AUDIT ====="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo ""

    echo "--- CPU ---"
    lscpu | grep -E "Model name|Architecture|CPU\(s\)|Core\(s\) per socket"
    echo ""

    echo "--- RAM ---"
    free -h | grep -E "Mem|Swap"
    echo ""

    echo "--- DISK ---"
    df -h
    echo ""
    echo "Partitions:"
    lsblk
    echo ""

    echo "--- GPU ---"
    if command -v lspci &>/dev/null; then
        lspci | grep -i "vga\|3d\|display" 2>/dev/null || echo "No GPU info found"
    else
        echo "lspci not available"
    fi
    echo ""

    echo "--- NETWORK INTERFACES ---"
    ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Network info unavailable"
    echo ""

    echo "--- MAC ADDRESSES ---"
    ip link show 2>/dev/null | grep "link/ether" || echo "MAC info unavailable"
    echo ""

    echo "--- MOTHERBOARD ---"
    if [ -r /sys/class/dmi/id/board_name ]; then
        echo "Board: $(cat /sys/class/dmi/id/board_name 2>/dev/null)"
        echo "Vendor: $(cat /sys/class/dmi/id/board_vendor 2>/dev/null)"
    else
        echo "Motherboard info requires root or not available"
    fi
    echo ""

    echo "--- USB DEVICES ---"
    lsusb 2>/dev/null || echo "lsusb not available"
    echo ""
}

# If run directly, print to stdout
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    collect_hardware_info
fi
