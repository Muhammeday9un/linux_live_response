Linux Live Response Script (SUSE / RHEL / Arch / Debian)

This project provides an **automated live response script** developed for **Digital Forensics and Incident Response (DFIR)** operations on Linux systems.  
It is optimized to work across **SUSE**, **RHEL/CentOS**, **Arch Linux**, and **Debian/Ubuntu** based distributions.

 Purpose

The goal of this script is to collect critical system artifacts **without shutting down the system** during an incident response process.  
The output is generated in **HTML format**, containing comprehensive live response data including:

- System information (hostname, OS type, version, kernel, timezone, installation/update dates)
- Network details (internal/external IPs, active connections, routing and ARP tables)
- User information, login history, and sudo privileges
- Running processes and active services
- File system details, recently created files, and `/tmp` contents
- Scheduled tasks (cron jobs)
- Recycle Bin contents and shared directories
- Clipboard data and mounted drives

 Features

- Automated HTML report generation  
- Multi-distro compatibility  
- Lightweight execution (read-only data collection)  
- Timestamped output files  
- Single-command execution  

 Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/Muhammeday9un/linux_live_response.git
   cd linux-live-response
Make the script executable:

    chmod +x live_response.sh

Run the script with root privileges:

    sudo ./live_response.sh
Open the generated HTML report:
firefox live_response_$(date +%Y%m%d_%H%M%S).html
