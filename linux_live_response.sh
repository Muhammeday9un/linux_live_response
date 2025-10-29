#!/usr/bin/env bash
# Live Response Script for SUSE Systems
# Collects forensic live-response data and outputs as HTML

OUTPUT_FILE="live_response_$(date +'%Y%m%d_%H%M%S').html"

# Start HTML
cat <<EOF > "$OUTPUT_FILE"
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Live Response Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h2 { border-bottom: 2px solid #333; }
    pre { background: #f4f4f4; padding: 10px; overflow-x: auto; }
  </style>
</head>
<body>
  <h1>Live Response Report - $(date -R)</h1>
EOF

# 1. Operating System & Host
cat <<EOF >> "$OUTPUT_FILE"
<h2>System Information</h2>
<pre>Hostname: $(hostname)</pre>
<pre>OS Release: $(grep '^PRETTY_NAME' /etc/os-release | cut -d '"' -f2)</pre>
<pre>Kernel: $(uname -r)</pre>
EOF
# Filesystem install date
ROOT_DEV=$(df / | awk 'END{print $1}')
CREATED=$(sudo tune2fs -l $ROOT_DEV 2>/dev/null | grep 'Filesystem created' | cut -d ':' -f2-)
cat <<EOF >> "$OUTPUT_FILE"
<pre>Filesystem Created: ${CREATED:-Not available}</pre>
EOF
# Last update (Zypper history)
UPDATED=$(stat -c '%y' /var/log/zypp/history 2>/dev/null)
cat <<EOF >> "$OUTPUT_FILE"
<pre>Last Package Update: ${UPDATED:-Not available}</pre>
EOF

# 2. Basic System Details
cat <<EOF >> "$OUTPUT_FILE"
<h2>Basic Details</h2>
<pre>Uptime: $(uptime -p)</pre>
<pre>Timezone: $(timedatectl | grep 'Time zone' | awk '{print $3, $4}')</pre>
EOF

# 3 & 12. Internal and External IP
cat <<EOF >> "$OUTPUT_FILE"
<h2>Network Addresses</h2>
<pre>Internal IPv4: $(hostname -I | awk '{print $1}')</pre>
<pre>External IP: $(curl -s ifconfig.me)</pre>
EOF

# 5. Installed Packages
cat <<EOF >> "$OUTPUT_FILE"
<h2>Installed Packages</h2>
<pre>$(rpm -qa --queryformat '%{NAME}\t%{VERSION}-%{RELEASE}\n' | sort)</pre>
EOF

# 6. Filesystem Types
cat <<EOF >> "$OUTPUT_FILE"
<h2>Filesystem Types</h2>
<pre>$(df -Th)</pre>
EOF

# 7 & 17. Active Network Connections
cat <<EOF >> "$OUTPUT_FILE"
<h2>Network Connections</h2>
<pre>$(ss -tunap)</pre>
EOF

# 8. Logged-in Users
cat <<EOF >> "$OUTPUT_FILE"
<h2>Logged-In Users</h2>
<pre>$(who)</pre>
EOF

# 9 & 20. Services and Daemons
cat <<EOF >> "$OUTPUT_FILE"
<h2>Services & Daemons (running)</h2>
<pre>$(systemctl list-units --type=service --state=running)</pre>
EOF

# 10. Running Processes
cat <<EOF >> "$OUTPUT_FILE"
<h2>Running Processes</h2>
<pre>$(ps -eo user,pid,ppid,%cpu,%mem,start_time,cmd --sort=start_time)</pre>
EOF

# 11. Open Files & Paths
cat <<EOF >> "$OUTPUT_FILE"
<h2>Open Files</h2>
<pre>$(lsof -nP)</pre>
EOF

# 13. Disk Drives
cat <<EOF >> "$OUTPUT_FILE"
<h2>Disk Drives</h2>
<pre>$(lsblk -f)</pre>
EOF

# 14. Clipboard Content
cat <<EOF >> "$OUTPUT_FILE"
<h2>Clipboard Content</h2>
<pre>$(which xclip &>/dev/null && xclip -o -selection clipboard || echo "No clipboard tool or no X session")</pre>
EOF

# 15. Mapped Drives
cat <<EOF >> "$OUTPUT_FILE"
<h2>Mapped Drives (mounts)</h2>
<pre>$(mount | column -t)</pre>
EOF

# 16 & 19. Shared Directories / Network Shares
cat <<EOF >> "$OUTPUT_FILE"
<h2>Shared Directories & Network Shares</h2>
<pre>Samba shares: $(which smbstatus &>/dev/null && smbstatus -S || echo "smbstatus not available")
NFS Exports: $(showmount -e localhost || echo "NFS exports unavailable")</pre>
EOF

# 18. Active Network Interfaces
cat <<EOF >> "$OUTPUT_FILE"
<h2>Active Network Interfaces</h2>
<pre>$(ip link show up)</pre>
EOF

# 21. Scheduled Tasks
cat <<EOF >> "$OUTPUT_FILE"
<h2>Scheduled Tasks</h2>
<pre>Global cron dirs: $(ls /etc/cron.*)
User crontabs:</pre>
EOF
for u in $(cut -f1 -d: /etc/passwd); do
  crontab -u $u -l 2>/dev/null | sed "s/^/  $u: /" >> "$OUTPUT_FILE"
done

# 22. Recycle Bin Files
cat <<EOF >> "$OUTPUT_FILE"
<h2>Recycle Bin</h2>
<pre>$(find ~/.local/share/Trash/files -type f 2>/dev/null)</pre>
EOF

# 23. Files Created in Last 36 Hours
cat <<EOF >> "$OUTPUT_FILE"
<h2>Files Created in Last 36 Hours</h2>
<pre>$(find / -xdev -type f -ctime -1.5 2>/dev/null)</pre>
EOF

# 24. Temporary Files
cat <<EOF >> "$OUTPUT_FILE"
<h2>Temporary Files</h2>
<pre>$(find /tmp -type f 2>/dev/null)</pre>
EOF

# End HTML
cat <<EOF >> "$OUTPUT_FILE"
</body>
</html>
EOF

echo "Report generated: $OUTPUT_FILE"
