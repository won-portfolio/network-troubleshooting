# NETWORK TROUBLESHOOTING SCRIPTS - INSTRUCTIONS & USAGE GUIDE

**Date:** [FILL IN]  
**Author:** [YOUR NAME]  
**Course:** CIS 245 - Linux Administration

---

## Quick Start

### Script 1: Network Information Dump
```bash
chmod +x network_info_dump.sh
./network_info_dump.sh
```

### Script 2: Interactive Troubleshooting
```bash
chmod +x network_troubleshoot.sh
./network_troubleshoot.sh
```

---

## Table of Contents

1. [Script 1: Network Information Dump](#script-1-network-information-dump)
2. [Script 2: Interactive Troubleshooting Guide](#script-2-interactive-troubleshooting-guide)
3. [Testing on Both Servers](#testing-on-both-servers)
4. [Output Locations](#output-locations)
5. [Screenshots Required](#screenshots-required)
6. [Verifying Output Matches](#verifying-output-matches)

---

## Script 1: Network Information Dump

### Purpose
Captures comprehensive network configuration and system information, outputs to both console and a timestamped file.

### File Location
- **Script location:** `network_info_dump.sh` (should be in home directory)
- **Output location:** `./network_dumps/network_dump_[timestamp]_[username]_[hostname].txt`

### How to Run

#### Step 1: Make Script Executable
```bash
chmod +x network_info_dump.sh
```

#### Step 2: Execute the Script
```bash
./network_info_dump.sh
```

#### Step 3: Script Will:
- Display colored output to console
- Create `network_dumps/` directory if it doesn't exist
- Save complete output to timestamped file
- Print the output file location at the end

### Expected Output

The script will display:
```
═══════════════════════════════════════════════════════════════════════════════
                  NETWORK INFORMATION DUMP SCRIPT
═══════════════════════════════════════════════════════════════════════════════

=== NETWORK INFORMATION DUMP SCRIPT ===
Output will be saved to: ./network_dumps/network_dump_2024-12-15_14-30-45_username_hostname.txt

=== SUMMARY ===
Report saved to: ./network_dumps/network_dump_2024-12-15_14-30-45_username_hostname.txt
File location: ./network_dumps/

✓ Script execution completed successfully
```

### Viewing the Output File

```bash
# View entire file
cat ./network_dumps/network_dump_*.txt

# View with pagination
less ./network_dumps/network_dump_*.txt

# Search for specific information
grep "IP addr" ./network_dumps/network_dump_*.txt

# View just a section
grep -A 20 "SECTION 1:" ./network_dumps/network_dump_*.txt
```

### What Each Section Captures

| Section | Contents | Why Important |
|---------|----------|---|
| 1 | System Info (OS, kernel, hostname, uptime) | Understand the underlying system |
| 2 | Network Interfaces (IPs, MACs, status) | Verify interfaces are up and configured |
| 3 | Routing (gateways, routes, metrics) | Check how traffic is routed |
| 4 | DNS (nameservers, resolution status) | Verify DNS configuration |
| 5 | NetworkManager (CentOS/RHEL) | Check connection profiles on CentOS |
| 6 | Netplan (Ubuntu) | Check network config on Ubuntu |
| 7 | Network Services | Verify services are running |
| 8 | Listening Ports | Check what services are accessible |
| 9 | ARP Table | Verify known network neighbors |
| 10 | Installed Tools | Confirm network tools are available |
| 11 | Tool Versions | Document what versions are installed |
| 12 | DNS Testing | Test DNS resolution |
| 13 | Connectivity Tests | Verify actual network connectivity |
| 14 | Interface Details | Hardware and driver info |
| 15 | Firewall | Check if firewall is blocking traffic |

### Sample Output Snippets

**Section 2: Network Interfaces**
```
ip addr show

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 08:00:27:b6:52:9d brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feb6:529d/64 scope link 
       valid_lft forever preferred_lft forever
```

**Section 3: Routing**
```
ip route show

default via 192.168.1.1 dev eth0 proto dhcp src 192.168.1.100 metric 100
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
```

**Section 8: Listening Ports**
```
ss -tuln

Netid   State    Recv-Q Send-Q   Local Address:Port      Peer Address:Port Process
tcp     LISTEN   0      128            0.0.0.0:22             0.0.0.0:*     
tcp     LISTEN   0      4096     127.0.0.53%lo:53             0.0.0.0:*     
```

### Commands Used in This Script

**Why each command was chosen:**

| Command | Purpose | Why Include |
|---------|---------|---|
| `ip addr show` | Modern interface/IP display | Linux Foundation recommended |
| `ifconfig` | Legacy interface display | Still widely used in production |
| `ip route show` | Modern routing table | Replaces old `route` command |
| `nmcli con show` | NetworkManager profiles | Standard on CentOS 9 |
| `netplan` files | Ubuntu network config | Standard on Ubuntu 18.04+ |
| `ss -tuln` | Modern port/socket info | Better than legacy netstat |
| `nslookup`/`dig` | DNS testing | Essential for DNS troubleshooting |
| `ping` | Connectivity testing | Basic verification of network |
| `tracepath` | Network path tracing | Identifies where issues occur |
| `firewall-cmd` | Firewall rules | Often the cause of "can't connect" issues |

---

## Script 2: Interactive Troubleshooting Guide

### Purpose
Interactive menu-driven script that provides troubleshooting steps specific to Ubuntu or CentOS 9.

### File Location
- **Script location:** `network_troubleshoot.sh`

### How to Run

#### Step 1: Make Script Executable
```bash
chmod +x network_troubleshoot.sh
```

#### Step 2: Execute
```bash
./network_troubleshoot.sh
```

#### Step 3: Follow the Menus

**First, you'll see:**
```
╔════════════════════════════════════════════════════════════════════════════════╗
║             NETWORK TROUBLESHOOTING GUIDE - INTERACTIVE                        ║
║         For Ubuntu & CentOS 9 Linux Servers                                    ║
╚════════════════════════════════════════════════════════════════════════════════╝

Which server type are you troubleshooting?

  1) Ubuntu (24.04 or similar)
  2) CentOS 9 Stream / RHEL 9
  3) Exit

Enter your choice (1-3): 
```

### Menu Options Explained

#### Option 1: No Internet Connectivity
Walks through the TCP/IP model layer by layer:
- **Physical/Link Layer:** Is interface up?
- **Network Layer:** Do we have an IP? Can we reach the gateway?
- **DNS:** Can we resolve hostnames?
- Includes server-specific commands for Ubuntu vs CentOS

**When to use:** "I have no internet at all" or "I just can't reach anything"

#### Option 2: Slow or Intermittent Connection
Diagnoses performance issues:
- Checks latency (ping response times)
- Packet loss
- Interface errors or dropped packets
- Bandwidth congestion
- DNS slowness
- Firewall rate limiting

**When to use:** "The network works but it's very slow" or "Connection drops intermittently"

#### Option 3: Configure Static IP Address
Step-by-step guide for setting a static IP:
- **Ubuntu:** Uses Netplan YAML format
- **CentOS:** Uses nmcli (NetworkManager) commands
- Shows the exact config format and commands needed

**When to use:** "I need to change from DHCP to static IP"

**Ubuntu example:**
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

**CentOS example:**
```bash
sudo nmcli con mod MyConnection \
  ipv4.method manual \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8 8.8.4.4"
```

#### Option 4: DNS Resolution Issues
Troubleshoots DNS problems:
- Check current DNS servers
- Test DNS lookups manually
- Try known-good DNS servers (Google, Cloudflare)
- Steps to change DNS servers

**When to use:** "Websites won't load by name but IP addresses work"

**Diagnosis sequence:**
1. `cat /etc/resolv.conf` — See current DNS
2. `nslookup google.com` — Test resolution
3. `nslookup google.com 8.8.8.8` — Test with known-good DNS
4. If #3 works, change your configured DNS

#### Option 5: Trace Network Path
Tools to trace the path to a destination:
- Interactive destination input
- `tracepath` (modern) or `traceroute` (legacy)
- Explanation of output
- Alternative ping-based tracing

**When to use:** "I can reach some hosts but not others" or "I want to see where the network path breaks"

**Output example:**
```
 0  ubuntu-server (192.168.1.100)
 1  gateway (192.168.1.1)                          1.234 ms
 2  isp-router (10.0.0.1)                          5.678 ms
 3  internet-backbone (203.0.113.1)               45.123 ms
 4  google (142.251.x.x)                          35.456 ms
    reached
```

#### Option 6: Check Listening Ports & Services
Shows which services are listening:
- Lists all listening ports
- Shows active connections
- Explains common port numbers
- How to check specific services

**When to use:** "I'm trying to connect to a service but it won't work"

**Key output:** `ss -tuln` shows:
```
State: LISTEN = port is open and listening
Proto: tcp = TCP protocol, udp = UDP protocol
Local Address: [IP]:[PORT] = listening on this port
```

#### Option 7: View All Network Configuration
Runs multiple commands in sequence:
- All interface info
- Routes
- DNS settings
- Listening ports
- Service status

**When to use:** "Just show me everything about my network"

#### Option 8: Change Server Type
Returns to the server selection menu to try troubleshooting for a different OS.

#### Option 9: Exit
Closes the script.

### Supported Server Types

**Ubuntu:**
- Netplan-based configuration
- systemd-networkd + systemd-resolved
- UFW firewall (typical)
- apt package manager

**CentOS 9:**
- NetworkManager-based configuration
- firewalld (typical)
- dnf/yum package manager
- /etc/NetworkManager/system-connections/

### Output Structure

Each troubleshooting section follows this pattern:

1. **Title** — What problem are we solving?
2. **Quick explanation** — What the commands do
3. **Step-by-step instructions** — How to diagnose
4. **What to look for** — Interpret the output
5. **Solutions** — How to fix the problem
6. **Server-specific commands** — Different for Ubuntu vs CentOS

---

## Testing on Both Servers

### Testing on Ubuntu Server

#### Run Network Info Dump
```bash
./network_info_dump.sh
# Wait for completion
ls -lh network_dumps/
cat network_dumps/network_dump_*.txt | head -50
```

#### Take Screenshot
```
Screenshot 1-Ubuntu: Network info dump console output
  • Show the colored output to console
  • Show the summary section
  • Show file location
```

#### Verify Output File
```bash
# Confirm file was created
ls -lh network_dumps/

# Sample output
grep "inet " network_dumps/network_dump_*.txt | head -5
grep "nameserver" network_dumps/network_dump_*.txt
```

#### Run Troubleshooting Script
```bash
./network_troubleshoot.sh
# Select option 1 (Ubuntu)
# Select option 1 (No Internet Connectivity)
# Review the menu and instructions
```

#### Take Screenshot
```
Screenshot 2-Ubuntu: Troubleshooting menu
  • Show the server selection
  • Show the main troubleshooting menu
```

### Testing on CentOS 9 Server

#### Run Network Info Dump
```bash
./network_info_dump.sh
# Wait for completion
ls -lh network_dumps/
cat network_dumps/network_dump_*.txt | head -50
```

#### Take Screenshot
```
Screenshot 3-CentOS: Network info dump console output
  • Show the colored output to console
  • Show the summary section
  • Show file location
```

#### Verify Output File
```bash
# Confirm file was created
ls -lh network_dumps/

# Sample output
grep "inet " network_dumps/network_dump_*.txt | head -5
grep "nameserver" network_dumps/network_dump_*.txt
```

#### Run Troubleshooting Script
```bash
./network_troubleshoot.sh
# Select option 2 (CentOS 9)
# Select option 3 (Configure Static IP)
# Review the menu and instructions
```

#### Take Screenshot
```
Screenshot 4-CentOS: Troubleshooting menu
  • Show the server selection
  • Show the main troubleshooting menu
```

---

## Output Locations

### Script Outputs

#### Network Info Dump Files
```
./network_dumps/
├── network_dump_2024-12-15_14-30-45_username_ubuntu.txt
├── network_dump_2024-12-15_14-35-22_username_centos9.txt
└── ...
```

**Each file contains:**
- Timestamp in filename
- Complete network configuration
- System information
- Service status
- Connectivity test results
- ~3000-5000 lines of output

#### File Naming Convention
```
network_dump_[DATE]_[TIME]_[USERNAME]_[HOSTNAME].txt

Example:
network_dump_2024-12-15_14-30-45_student_ubuntu-server.txt
```

### Script Locations

Keep scripts in a dedicated folder:
```
~/network_scripts/
├── network_info_dump.sh
├── network_troubleshoot.sh
└── network_dumps/  (output directory created by dump script)
```

### How to Transfer Scripts Between Servers

**Copy to USB/Shared folder:**
```bash
# On source server
cp network_info_dump.sh /mnt/shared/
cp network_troubleshoot.sh /mnt/shared/

# On target server
cp /mnt/shared/network_*.sh ~/
chmod +x ~/*.sh
```

**Via SSH (if servers are networked):**
```bash
# From your local computer
scp network_info_dump.sh user@centos-server:~/
scp network_troubleshoot.sh user@centos-server:~/

# Or use SCP from one server to another
ssh user@centos-server "scp user@ubuntu-server:~/network_info_dump.sh ~/"
```

---

## Screenshots Required

For your deliverables, capture:

### Screenshots for Ubuntu

1. **network_info_dump.sh — Console execution**
   - Show the colored output
   - Show section headers
   - Show the completion message
   - File size and location

2. **network_info_dump.sh — Output file content**
   - Show first 50 lines (system info, interfaces)
   - Show DNS section
   - Show listening ports section

3. **network_troubleshoot.sh — Server selection menu**
   - Show the title
   - Show server options (select Ubuntu)

4. **network_troubleshoot.sh — Main menu**
   - Show all troubleshooting options

5. **Your network configuration**
   - IP address and interface name
   - Default gateway
   - DNS servers
   - One listening service/port

### Screenshots for CentOS 9

(Same as above, but for CentOS)

1. network_info_dump.sh console output
2. network_info_dump.sh file content
3. Server selection (select CentOS)
4. Main troubleshooting menu
5. Network configuration details

---

## Verifying Output Matches System

### Quick Verification Commands

Compare script output with live commands:

```bash
# Script showed this interface
inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0

# Verify with live command
ip addr show | grep "inet " | grep -v "127.0.0.1"

# Should show same IP
```

```bash
# Script showed this gateway
default via 192.168.1.1 dev eth0 proto dhcp

# Verify with live command
ip route show | grep default

# Should show same gateway
```

```bash
# Script showed these DNS servers
nameserver 8.8.8.8
nameserver 8.8.4.4

# Verify with live command
cat /etc/resolv.conf | grep nameserver

# Should show same DNS
```

### Command-by-Command Verification

**Verify Interfaces:**
```bash
# From script output:
# Section 2: NETWORK INTERFACES
# IP: 192.168.1.100/24, Interface: eth0

# Live verification:
ip addr show

# Cross-check IP and interface name match
```

**Verify DNS:**
```bash
# From script output:
# Section 4: DNS - nameserver 8.8.8.8

# Live verification:
cat /etc/resolv.conf
resolvectl status

# Cross-check DNS servers match
```

**Verify Services:**
```bash
# From script output:
# Section 7: systemd-networkd is running

# Live verification:
systemctl status systemd-networkd

# Should show "active (running)"
```

**Verify Listening Ports:**
```bash
# From script output:
# Section 8: LISTEN port 22

# Live verification:
ss -tuln | grep ":22"

# Should show SSH listening
```

---

## Common Issues & Solutions

### Script Won't Run

**Problem:** `bash: ./network_info_dump.sh: Permission denied`

**Solution:**
```bash
chmod +x network_info_dump.sh
# Then run again
./network_info_dump.sh
```

### No Output File Created

**Problem:** No network_dumps directory or files

**Solution:**
```bash
# Check if directory exists
ls -la network_dumps/

# If doesn't exist, create it
mkdir -p network_dumps/

# Re-run script
./network_info_dump.sh
```

### Some Commands Show "Permission Denied"

**Expected behavior** — Many commands require sudo. Script continues without failure.

**To get full output, run with sudo:**
```bash
sudo ./network_info_dump.sh
```

### Script Hangs on Connectivity Tests

**Why:** `ping` and `curl` wait for responses. If there's no internet, these timeout (~3-10 seconds each).

**Expected behavior** — Script waits and then continues

**To skip connectivity tests**, interrupt the script (Ctrl+C) and view the output file that was created.

---

## Advanced Usage

### Filter Output for Specific Info

**Find your IP address:**
```bash
grep "inet " network_dumps/network_dump_*.txt | grep -v "127.0.0.1"
```

**Find listening services:**
```bash
grep "LISTEN" network_dumps/network_dump_*.txt
```

**Find DNS configuration:**
```bash
grep "nameserver" network_dumps/network_dump_*.txt
```

**Find routing table:**
```bash
grep -A 10 "Routing Table" network_dumps/network_dump_*.txt
```

### Compare Two Runs

Check what changed between two runs:

```bash
# Create baseline
./network_info_dump.sh
mv network_dumps/network_dump_*_ubuntu.txt baseline_ubuntu.txt

# Make a change to network config
# ... edit /etc/netplan/...

# Create new dump
./network_info_dump.sh

# Compare
diff baseline_ubuntu.txt network_dumps/network_dump_*_ubuntu.txt
```

### Share with Others

```bash
# Email or upload the dump file to share findings
ls -lh network_dumps/
scp network_dumps/network_dump_*.txt user@remote:/path/to/archive/
```

---

## Deliverables Checklist

For this assignment, ensure you have:

### For UBUNTU Server:
- [ ] Completed network setup documentation (NETWORK_SETUP_UBUNTU.md)
- [ ] Screenshot of network_info_dump.sh execution on Ubuntu
- [ ] Screenshot of network_info_dump.sh output file on Ubuntu
- [ ] Output file from network_info_dump.sh on Ubuntu
- [ ] Screenshot of network_troubleshoot.sh main menu on Ubuntu
- [ ] Verification that output matches actual network settings

### For CENTOS 9 Server:
- [ ] Completed network setup documentation (NETWORK_SETUP_CENTOS9.md)
- [ ] Screenshot of network_info_dump.sh execution on CentOS
- [ ] Screenshot of network_info_dump.sh output file on CentOS
- [ ] Output file from network_info_dump.sh on CentOS
- [ ] Screenshot of network_troubleshoot.sh main menu on CentOS
- [ ] Verification that output matches actual network settings

### For Both Servers:
- [ ] network_info_dump.sh script (well-commented, tested)
- [ ] network_troubleshoot.sh script (well-commented, tested)
- [ ] Research document on script design decisions
- [ ] This instructions document
- [ ] Links to GitHub repository (with scripts uploaded)

---

## Next Steps

1. **Copy scripts to both servers**
2. **Run network_info_dump.sh on each and capture screenshots**
3. **Verify output matches actual configuration**
4. **Run network_troubleshoot.sh and explore menus**
5. **Complete the network setup documentation for each server**
6. **Upload scripts to GitHub**
7. **Create a summary comparing the two servers**

---

**Document Complete**

For questions or issues with the scripts, review the inline comments in each script file.
