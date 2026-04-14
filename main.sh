#!/bin/bash
# main.sh

SCRIPT_DIR="$(cd "$(dirname "$0")/scripts" && pwd)"
LOG_DIR="$(cd "$(dirname "$0")" && pwd)/logs"
LOG_FILE="$LOG_DIR/audit.log"
mkdir -p "$LOG_DIR"

#Colors
RED='\033[0;31m';    GREEN='\033[0;32m';   YELLOW='\033[1;33m'
BLUE='\033[0;34m';   CYAN='\033[0;36m';   MAGENTA='\033[0;35m'
WHITE='\033[1;37m';  BOLD='\033[1m';       DIM='\033[2m';  RESET='\033[0m'
BG_BLUE='\033[44m';  BG_BLACK='\033[40m'

#Helpers
log()     { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
info()    { echo -e "  ${CYAN}[*]${RESET} $1"; }
success() { echo -e "  ${GREEN}[✔]${RESET} $1"; }
warn()    { echo -e "  ${YELLOW}[!]${RESET} $1"; }
error()   { echo -e "  ${RED}[✘]${RESET} $1"; }
pause()   { echo ""; read -rp "$(echo -e "  ${DIM}Press Enter to return to menu...${RESET}")"; }

# Draw a simple bar chart
draw_bar() {
    local pct=$1   # 0-100
    local width=20
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local bar=""
    local color

    if   [ "$pct" -ge 80 ]; then color=$RED
    elif [ "$pct" -ge 50 ]; then color=$YELLOW
    else                          color=$GREEN
    fi

    for (( i=0; i<filled; i++ )); do bar+="█"; done
    for (( i=0; i<empty;  i++ )); do bar+="░"; done
    echo -e "${color}${bar}${RESET} ${BOLD}${pct}%${RESET}"
}

#Banner
print_banner() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║    ██╗      █████╗ ███╗   ███╗███████╗                      ║"
    echo "  ║    ██║     ██╔══██╗████╗ ████║██╔════╝                      ║"
    echo "  ║    ██║     ███████║██╔████╔██║███████╗                      ║"
    echo "  ║    ██║     ██╔══██║██║╚██╔╝██║╚════██║                      ║"
    echo "  ║    ███████╗██║  ██║██║ ╚═╝ ██║███████║                      ║"
    echo "  ║    ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝                      ║"
    echo "  ║                                                              ║"
    echo "  ║         Linux Audit & Monitoring System  v1.0               ║"
    echo "  ║       National School of Cyber Security – 2025/2026         ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"

    # System info row
    echo -e "  ${DIM}┌─────────────────────────────────────────────────────────────┐${RESET}"
    printf   "  ${DIM}│${RESET}  ${BOLD}%-10s${RESET} %-22s  ${BOLD}%-8s${RESET} %-20s ${DIM}│${RESET}\n" \
             "Host:"    "$(hostname)"                  "User:"   "$(whoami)"
    printf   "  ${DIM}│${RESET}  ${BOLD}%-10s${RESET} %-22s  ${BOLD}%-8s${RESET} %-20s ${DIM}│${RESET}\n" \
             "Kernel:"  "$(uname -r)"                  "Uptime:" "$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | cut -d',' -f1)"
    printf   "  ${DIM}│${RESET}  ${BOLD}%-10s${RESET} %-50s ${DIM}│${RESET}\n" \
             "Date:"    "$(date '+%A, %d %B %Y   %H:%M:%S')"
    echo -e "  ${DIM}└─────────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    # Resource bars
    local cpu_idle cpu_pct ram_pct disk_pct
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d '%' | cut -d'.' -f1 2>/dev/null || echo 0)
    cpu_pct=$(( 100 - cpu_idle ))
    ram_pct=$(free | awk '/Mem/ {printf "%.0f", $3/$2*100}')
    disk_pct=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    printf "  ${BOLD}  CPU  ${RESET}"; draw_bar "$cpu_pct"
    printf "  ${BOLD}  RAM  ${RESET}"; draw_bar "$ram_pct"
    printf "  ${BOLD}  DISK ${RESET}"; draw_bar "$disk_pct"
    echo ""
    echo -e "  ${BLUE}──────────────────────────────────────────────────────────────${RESET}"
}

# Menu
print_menu() {
    echo ""
    echo -e "  ${BOLD}${WHITE}  ◈  MAIN MENU${RESET}"
    echo ""
    echo -e "  ${DIM}  ┌──────────────────────────────────┐${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${CYAN}${BOLD}REPORTS${RESET}                          ${DIM}│${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${YELLOW} 1 ${RESET} Generate Short Report            ${DIM}│${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${YELLOW} 2 ${RESET} Generate Full Report             ${DIM}│${RESET}"
    echo -e "  ${DIM}  ├──────────────────────────────────┤${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${CYAN}${BOLD}ACTIONS${RESET}                          ${DIM}│${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${YELLOW} 3 ${RESET} Send Report by Email             ${DIM}│${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${YELLOW} 4 ${RESET} Remote Monitor via SSH           ${DIM}│${RESET}"
    echo -e "  ${DIM}  ├──────────────────────────────────┤${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${CYAN}${BOLD}SYSTEM${RESET}                           ${DIM}│${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${YELLOW} 5 ${RESET} View Audit Log                   ${DIM}│${RESET}"
    echo -e "  ${DIM}  │${RESET}  ${RED} 6 ${RESET} Exit                             ${DIM}│${RESET}"
    echo -e "  ${DIM}  └──────────────────────────────────┘${RESET}"
    echo ""
    echo -e "  ${BLUE}──────────────────────────────────────────────────────────────${RESET}"
    echo ""
}

# Section header 
section() {
    echo ""
    echo -e "  ${BLUE}${BOLD}┌─ $1 ${RESET}"
    echo ""
}

# Actions 
do_short_report() {
    section "Generate Short Report"
    info "Running hardware and software collection..."
    log "Generating short report"
    OUTPUT=$(bash "$SCRIPT_DIR/report_gen.sh" short 2>&1)
    SAVED=$(echo "$OUTPUT" | grep "saved to")
    if [ -n "$SAVED" ]; then
        success "$SAVED"
        log "Short report done – $SAVED"
    else
        error "Something went wrong:"
        echo "$OUTPUT"
        log "Short report failed"
    fi
    pause
}

do_full_report() {
    section "Generate Full Report"
    info "Running full audit, this may take a few seconds..."
    log "Generating full report"
    OUTPUT=$(bash "$SCRIPT_DIR/report_gen.sh" full 2>&1)
    SAVED=$(echo "$OUTPUT" | grep "saved to")
    if [ -n "$SAVED" ]; then
        success "$SAVED"
        log "Full report done – $SAVED"
    else
        error "Something went wrong:"
        echo "$OUTPUT"
        log "Full report failed"
    fi
    pause
}

do_send_email() {
    section "Send Report by Email"
    warn "Make sure ~/.msmtprc is configured before sending."
    echo ""
    read -rp "$(echo -e "  ${BOLD}Path to report file: ${RESET}")" rpath
    if [ -z "$rpath" ]; then
        warn "No path entered. Cancelled."
        pause; return
    fi
    if [ ! -f "$rpath" ]; then
        error "File not found: $rpath"
        pause; return
    fi
    info "Sending..."
    log "Sending email for $rpath"
    bash "$SCRIPT_DIR/send_report.sh" "$rpath"
    if [ $? -eq 0 ]; then
        success "Email sent successfully."
        log "Email sent for $rpath"
    else
        error "Failed. Check your ~/.msmtprc configuration."
        log "Email failed for $rpath"
    fi
    pause
}

do_remote_monitor() {
    section "Remote Monitor via SSH"
    warn "Requires SSH key-based login to be set up (no password prompt)."
    warn "Edit REMOTE_USER and REMOTE_HOST inside scripts/remote_monitor.sh first."
    echo ""
    read -rp "$(echo -e "  ${BOLD}Continue? [y/N]: ${RESET}")" confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        info "Cancelled."
        pause; return
    fi
    info "Connecting to remote machine..."
    log "Starting remote monitor"
    bash "$SCRIPT_DIR/remote_monitor.sh"
    if [ $? -eq 0 ]; then
        success "Remote audit completed successfully."
        log "Remote monitor done"
    else
        error "Remote monitor failed. Check REMOTE_HOST / REMOTE_USER and SSH access."
        log "Remote monitor failed"
    fi
    pause
}

do_view_log() {
    section "Audit Log"
    if [ ! -f "$LOG_FILE" ] || [ ! -s "$LOG_FILE" ]; then
        warn "Log file is empty or does not exist yet."
    else
        echo -e "  ${DIM}Showing last 20 entries from: $LOG_FILE${RESET}"
        echo ""
        tail -20 "$LOG_FILE" | while IFS= read -r line; do
            # Color lines that contain keywords
            if echo "$line" | grep -q "failed\|error\|Error"; then
                echo -e "  ${RED}│${RESET} $line"
            elif echo "$line" | grep -q "done\|sent\|completed"; then
                echo -e "  ${GREEN}│${RESET} $line"
            else
                echo -e "  ${DIM}│${RESET} $line"
            fi
        done
    fi
    pause
}

# Main loop 
while true; do
    print_banner
    print_menu
    read -rp "$(echo -e "  ${BOLD}Your choice [1-6]: ${RESET}")" choice
    case $choice in
        1) do_short_report ;;
        2) do_full_report ;;
        3) do_send_email ;;
        4) do_remote_monitor ;;
        5) do_view_log ;;
        6)
            echo ""
            success "Goodbye."
            log "Session ended"
            echo ""
            exit 0
            ;;
        *)
            warn "Invalid option. Enter a number between 1 and 6."
            sleep 1
            ;;
    esac
done
