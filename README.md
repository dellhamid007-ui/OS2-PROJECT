# Linux System Audit & Monitoring – Mini Project Part 1

## What this project does

This is a set of Bash scripts that automatically collects hardware and software info from a Linux machine and saves it as a text report. You can also send the report by email and run it on a remote machine via SSH.

---

## File Structure

```
sys_audit_project/
├── main.sh                    ← Start here (interactive menu)
├── scripts/
│   ├── hardware_audit.sh      ← Collects CPU, RAM, Disk, etc.
│   ├── software_audit.sh      ← Collects OS, packages, ports, etc.
│   ├── report_gen.sh          ← Generates short or full .txt reports
│   ├── send_report.sh         ← Sends a report file by email
│   └── remote_monitor.sh      ← Runs audit on a remote machine via SSH
├── reports/                   ← Reports get saved here (or /var/log/sys_audit/)
├── logs/                      ← Execution logs
└── README.md
```

---

## Installation

No installation needed. Just make the scripts executable:

```bash
chmod +x main.sh scripts/*.sh
```

---

## How to Run

### Interactive menu (recommended):
```bash
./main.sh
```

### Or run individual scripts directly:
```bash
# Generate a short summary report
./scripts/report_gen.sh short

# Generate a full detailed report
./scripts/report_gen.sh full

# Send a report by email
./scripts/send_report.sh /path/to/report.txt

# Monitor a remote machine
./scripts/remote_monitor.sh
```

---

## Configuration

### Email (send_report.sh)
Open `scripts/send_report.sh` and change:
```bash
RECIPIENT="your_email@example.com"
```

To use `msmtp`, install it and configure `~/.msmtprc`:
```
account default
host smtp.gmail.com
port 587
auth on
tls on
user your_email@gmail.com
password your_app_password
from your_email@gmail.com
```
Then: `chmod 600 ~/.msmtprc`

### Remote Monitoring (remote_monitor.sh)
Open `scripts/remote_monitor.sh` and change:
```bash
REMOTE_USER="user"
REMOTE_HOST="192.168.1.100"
```
Make sure SSH key-based login is set up (no password prompt).

---

## Cron Job (Automation)

To run the full report every day at 4:00 AM, add this to your crontab:

```bash
crontab -e
```

Add the line:
```
0 4 * * * /full/path/to/scripts/report_gen.sh full >> /full/path/to/logs/audit.log 2>&1
```

---

## Notes

- Reports are saved to `/var/log/sys_audit/` if you have root access, otherwise to `./reports/`
- Logs go to `./logs/audit.log`
- Some commands (like `lspci`, `lsusb`) may need to be installed: `sudo apt install pciutils usbutils`
