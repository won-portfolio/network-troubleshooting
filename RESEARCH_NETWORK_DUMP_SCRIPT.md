# Network Information Dump Script - Research & Design Document
**Research on Included Commands and Additions**

**Date:** [FILL IN]  
**Author:** [YOUR NAME]  
**Course:** CIS 245 - Linux Administration  
**Assignment:** Network Troubleshooting Project

---

## Executive Summary

The network information dump script (`network_info_dump.sh`) was designed to gather comprehensive network data in a single execution, producing both console output and a timestamped file. This document explains the rationale behind each command category, why these specific tools were selected, and how they contribute to effective system administration and troubleshooting.

---

## 1. System Information Section

### Commands Included
- `uname -a` — Kernel and system architecture
- `/etc/os-release` — OS identification and version
- `lsb_release -a` — LSB version info (Ubuntu)
- `/etc/redhat-release` — Red Hat release info (CentOS)
- `uptime` — System uptime and load average

### Rationale

**Why this matters:** Understanding the underlying system is critical for troubleshooting. Different OS versions and kernels behave differently with networking.

**Specific benefits:**
- **Kernel version** affects networking stack performance and features
- **OS version** determines which networking tools are available (e.g., Netplan on Ubuntu 18.04+, NetworkManager on CentOS 9)
- **Architecture** (x86_64 vs ARM) affects driver availability
- **Uptime** tells us if the system recently rebooted (which may have reset network state)
- **Load average** helps identify if network slowness is due to system overload

**Sources:**
- Linux Foundation documentation on system identification
- Red Hat/CentOS official documentation on versioning

---

## 2. Network Interfaces Section (Modern vs Legacy)

### Commands Included

**Modern approach:**
- `ip addr show` — Interfaces and assigned IP addresses
- `ip link show` — Interface status and MAC addresses
- `ip -s link show` — Interface statistics (packets, errors)

**Legacy approach:**
- `ifconfig` — All-in-one interface info (from net-tools)

### Rationale

**Modern commands (ip):**
- `ip` is the recommended command by Linux Foundation and RHEL/Debian maintainers
- More detailed output and better parsing capabilities
- Supports IPv6 natively
- Used in all modern Linux distributions

**Legacy commands (ifconfig):**
- Still widely used, especially in production systems
- Administrators familiar with older Linux versions prefer it
- Essential for troubleshooting on systems where `ip` may not be available
- Part of net-tools package (as specified in assignment)

**Why include both:**
The script provides both modern and legacy output to serve administrators at different skill levels and working with different systems. As the PowerPoint noted, there's significant variability by distro, and "change is unwelcome by some in the community."

**Specific outputs captured:**
- Interface name (eth0, ens33, enp0s3, etc.)
- IPv4 and IPv6 addresses
- MAC addresses (media access control)
- Interface status (UP/DOWN)
- Packet statistics (RX/TX counts, drops, errors)

---

## 3. Routing Configuration Section

### Commands Included
- `ip route show` — Kernel routing table
- `route -n` — Legacy routing table with numeric IPs
- `netstat -rn` — Alternative legacy routing display

### Rationale

**Why routing is critical:**
Routing determines how packets reach their destination. A missing default gateway or incorrect route is the most common networking issue.

**What this captures:**
- Default gateway (critical for internet access)
- Subnet routes
- Host-specific routes
- Metric values (used for choosing between multiple routes)

**Why multiple commands:**
- `ip route show` — Modern standard
- `route -n` — Legacy but widely known
- `netstat -rn` — Older systems may only have netstat

**Real-world scenario:**
A server loses internet access. The first diagnostic step is checking routing: `ip route show`. If no default gateway is present, that's the problem.

---

## 4. DNS and Name Resolution Section

### Commands Included
- `/etc/resolv.conf` — System resolver configuration
- `/etc/hostname` — Hostname file
- `/etc/hosts` — Static hostname mappings
- `resolvectl status` — systemd-resolved status
- `systemctl status systemd-resolved` — DNS service status
- DNS testing commands (nslookup, dig, host)

### Rationale

**Why DNS is included:**
According to the assignment video, DNS configuration is one of the "things you should worry about first." Misconfigured DNS is a common cause of apparent connectivity issues.

**What's captured:**
- Active nameservers being used
- DNS search domains
- systemd-resolved status (on modern systems)
- Whether the system can resolve hostnames to IPs

**Why separate from networking:**
DNS is handled separately because it operates at the Application layer (Layer 5) of the TCP/IP model, distinct from network layer configuration.

**Source:** The class PowerPoint explicitly lists "Setting DNS" as a primary concern.

---

## 5. NetworkManager Section (CentOS 9)

### Commands Included
- `nmcli device show` — All device information
- `nmcli con show` — Connection profiles
- `systemctl status NetworkManager` — Service status
- Directory listing of `/etc/NetworkManager/system-connections/`

### Rationale

**Why NetworkManager:**
According to the assignment materials, CentOS 9 uses NetworkManager as the default service (vs. older RHEL 7 which used network scripts in `/etc/init.d/network`).

**What's captured:**
- Which connections are defined
- Which connection is active
- IP configuration method (DHCP vs static)
- DNS servers configured in each connection
- Device status and IP addresses

**Real-world value:**
A common CentOS 9 issue is multiple conflicting connection profiles. This script helps identify which one is active and whether the active one is correctly configured.

**Source:** Week 5 PowerPoint explicitly compares Red Hat 7 vs RHEL 9 networking approaches.

---

## 6. Netplan Section (Ubuntu)

### Commands Included
- Directory listing of `/etc/netplan/`
- Content of Netplan YAML files
- `systemctl status systemd-networkd` — Service status

### Rationale

**Why Netplan:**
Ubuntu 18.04+ moved to Netplan as the primary network configuration tool. Netplan is a YAML-based abstraction layer that can use either systemd-networkd or NetworkManager as backend.

**What's captured:**
- The actual network configuration (IP addresses, gateways, DNS)
- Which interfaces are configured
- DHCP vs static configuration
- Netplan service status

**Why separate from NetworkManager:**
Netplan is not the same as NetworkManager. Ubuntu typically uses Netplan + systemd-networkd on servers, vs. Netplan + NetworkManager on desktops.

**Source:** Week 5 PowerPoint specifically lists `/etc/network/interfaces` and related files for Debian systems.

---

## 7. Listening Ports and Connections Section

### Commands Included
- `ss -tuln` — Modern socket statistics (TCP/UDP, numeric)
- `ss -tuan` — All TCP/UDP connections
- `ss -l` — All listening sockets
- `netstat -tuln` / `netstat -an` — Legacy alternatives

### Rationale

**Why listening ports matter:**
The assignment references the TCP/IP model for troubleshooting. Transport layer (Layer 4) issues include closed ports or blocked services. This section diagnoses those problems.

**What's captured:**
- Which ports are listening for incoming connections
- Whether connections are waiting or established
- Process information (if run with appropriate permissions)

**Modern vs Legacy:**
- `ss` is the modern replacement for netstat (faster, more features)
- `netstat` is legacy but still available on older systems
- Both show similar information, but `ss` is recommended

**Real-world scenario:**
"I can't SSH into the server" — First check: `sudo ss -tuln | grep 22`. If port 22 isn't listening, SSH daemon isn't running.

---

## 8. ARP Table Section

### Commands Included
- `arp -n` — Address Resolution Protocol table
- `ip neighbor show` — Modern equivalent

### Rationale

**TCP/IP Model Application:**
The assignment video mentions checking the Data Link layer (Layer 2) for issues. ARP operates at Layer 2/3 and maps IP addresses to MAC addresses.

**What's captured:**
- Known network neighbors (devices we've communicated with)
- Their MAC addresses
- Whether ARP entries are incomplete (indicates communication problem)

**Why it matters:**
If a device's ARP entry is marked "incomplete," it means we can't reach them at the Data Link layer, even if they have an IP address.

**Real-world scenario:**
A server can't reach another server on the same subnet. Check ARP: `arp -n | grep [target-ip]`. If it's not there or incomplete, there's a Layer 2 connectivity issue.

---

## 9. Installed Network Tools Section

### Commands Included
- Package listing by distribution (apt for Ubuntu, dnf/rpm for CentOS)
- Filtering for network-related packages
- Version information for key tools

### Rationale

**Why this matters:**
Different distributions install different tools by default. Knowing what's available is crucial for troubleshooting.

**What's captured:**
- Whether net-tools is installed (assignment requirement)
- Installed versions of key tools (iproute2, systemd-resolved, tcpdump, etc.)
- Which tools are available for troubleshooting

**Why separated by distribution:**
Ubuntu uses `apt` and Debian packages, CentOS uses `dnf`/`rpm`. This section shows both approaches.

**Source:** The assignment specifically requires installing and documenting net-tools.

---

## 10. Network Services Status Section

### Commands Included
- `systemctl status networking` — Ubuntu networking service
- `systemctl status network` — Legacy Red Hat service
- `systemctl status systemd-networkd` — Modern network daemon
- `systemctl status systemd-resolved` — DNS daemon
- `systemctl list-units --type=service | grep network` — All network services

### Rationale

**Why service status matters:**
A network problem might be due to a service not running. This section shows which services are active.

**What's captured:**
- Is the main networking service running?
- Is DNS resolution service running?
- Are there any service errors or failures?

**Why multiple services listed:**
Different systems use different services:
- Ubuntu servers: systemd-networkd + systemd-resolved
- CentOS 9: NetworkManager + systemd-resolved
- Older systems: plain `network` service

---

## 11. DNS Testing Section

### Commands Included
- `nslookup google.com` — Basic DNS lookup
- `dig google.com` — Detailed DNS lookup with full response
- `host google.com` — Simple host lookup
- `getent hosts localhost` — Local resolution check

### Rationale

**Why DNS testing is separate:**
DNS is often the culprit when "internet doesn't work but I have an IP address." This section tests DNS specifically.

**What's captured:**
- Can we resolve hostnames to IPs?
- Are DNS servers responding?
- Is the local hostname resolution working?

**Why multiple tools:**
- `nslookup` — Most common, familiar to network admins
- `dig` — Shows full DNS response (query, answer, authority)
- `host` — Simple, straightforward output
- `getent` — Checks local resolution (hosts file, hostname database)

**Real-world scenario:**
`ping google.com` fails but `ping 8.8.8.8` works → DNS problem. This section helps diagnose it.

---

## 12. Network Connectivity Tests Section

### Commands Included
- `ping -c 3 8.8.8.8` — Test basic internet connectivity
- `ping -c 3 google.com` — Test DNS + connectivity together
- `tracepath google.com` — Trace network path
- `curl https://www.google.com` — HTTP connectivity test

### Rationale

**TCP/IP Model Troubleshooting:**
The assignment emphasizes using the TCP/IP model to troubleshoot. These commands test each layer:
- **Ping IP** (Layer 3 — Network) — Tests routing and basic connectivity
- **Ping hostname** (Layer 3 + 5 — Network + Application) — Tests DNS + routing
- **Tracepath** (Layer 3) — Shows where in the network path the problem is
- **Curl** (Layer 5 — Application) — Tests if HTTP service works

**Why these specific hosts:**
- Google DNS (8.8.8.8) — Reliable, always-on external target
- google.com — Known, widely available hostname
- Tests both IP connectivity and DNS resolution

**Source:** The PowerPoint lists these commands in the "Important commands to know" section.

---

## 13. Interface Details (ethtool) Section

### Commands Included
- `ethtool [interface]` — Hardware details
- `ethtool -i [interface]` — Driver information
- `ethtool -S [interface]` — Detailed statistics

### Rationale

**Why ethtool:**
Goes deeper than basic interface status. Shows hardware capabilities and driver information.

**What's captured:**
- NIC capabilities (speed, duplex mode, offloading features)
- Driver name and version
- Detailed packet/error statistics

**When useful:**
- Diagnosing performance issues (check if interface is running at full speed)
- Identifying driver problems
- Understanding hardware limitations

**Conditional inclusion:**
Only runs on active interfaces to avoid unnecessary output.

---

## 14. Firewall Section

### Commands Included
- `systemctl status firewalld` — CentOS/RHEL firewall
- `firewall-cmd --list-all` — Firewall rules
- `systemctl status ufw` — Ubuntu firewall
- `sudo iptables -L -n` — Underlying iptables rules

### Rationale

**Why firewall is included:**
A common network troubleshooting scenario: "I can reach the server from the local network but not from outside." This is usually a firewall issue, not a network configuration issue.

**What's captured:**
- Which firewall is active (firewalld vs ufw vs iptables)
- What rules are in place
- Blocked ports or connections

**Real-world scenario:**
Server has an IP, DNS works, but you can't access a service. First check: `sudo firewall-cmd --list-all` or `sudo ufw status`. The port might be blocked.

**Why different tools per distro:**
- CentOS 9: Uses firewalld by default
- Ubuntu: Uses UFW by default
- Both can use underlying iptables

---

## Additions Not Included (and Why)

### Not Included: IPv6 Configuration
While IPv6 is important, the focus of the assignment is on foundational troubleshooting. IPv6 would be a natural extension but adds complexity for a first network documentation effort.

### Not Included: VPN/Tunnel Interfaces
Most student servers won't have VPN or tunnel interfaces. The script focuses on standard Ethernet/IP networking.

### Not Included: Detailed Performance Metrics
Commands like `sar` or `nethogs` require additional tools. The script uses built-in tools available on all systems.

---

## Design Decisions

### 1. Dual Output (Console + File)

**Why:** The assignment requires both console output and a file. Having both allows:
- Immediate visual feedback
- Permanent record for later analysis
- Timestamped filename prevents accidental overwrites

### 2. Timestamped Filename

**Why:** Identifies when the dump was created, useful for comparing multiple runs.
Format: `network_dump_2024-12-15_14-30-45_username_hostname.txt`

### 3. Color-Coded Output

**Why:** Makes the console output easier to scan. Different colors indicate:
- Section headers (blue)
- Important information (yellow)
- Success messages (green)
- Errors (red)

### 4. Comments Within Script

**Why:** Every section is explained, making it easy for students to understand what each command does and why it's useful.

### 5. Fallback Commands

**Why:** Some commands might not exist on all systems. The script uses `||` (OR) to try alternative commands:
```bash
resolvectl status 2>/dev/null || cat /etc/resolv.conf
```

---

## How This Script Supports the Assignment Requirements

### Requirement 1: Network Configuration
✓ Captures all network files, interfaces, routing, DNS, and service status

### Requirement 2: System Information
✓ Includes OS version, kernel, hostname, uptime

### Requirement 3: Comprehensive Output
✓ 14 major sections covering all networking aspects
✓ Both modern and legacy commands for completeness

### Requirement 4: Format and Usability
✓ Clear section headers and organization
✓ Command shown before output for learning
✓ Explanatory notes on what to look for

### Requirement 5: Supports Troubleshooting
✓ Organized by TCP/IP model layers
✓ Captures data needed for common diagnoses
✓ Both output formats (console + file)

---

## Real-World Value

This script provides value beyond the classroom:

1. **Documentation** — Creates a baseline configuration record
2. **Troubleshooting** — Captures all relevant data in one run
3. **Training** — Shows students what information matters for network admin
4. **Portability** — Works on both Ubuntu and CentOS
5. **Extensibility** — Can be easily modified to add more sections

---

## Lessons Learned & Future Improvements

### Potential Additions:
- IPv6 configuration and testing
- VPN/tunnel interface detection
- Performance metrics (latency, jitter)
- Packet capture with tcpdump
- Container networking (if Docker/Kubernetes in use)

### Possible Modifications:
- Interactive menu to select which sections to run
- Email output to administrator
- Integration with monitoring tools (Prometheus, Grafana)
- Comparison of multiple snapshots to show changes

---

## Conclusion

The network information dump script brings together modern and legacy tools, covering all layers of the TCP/IP model. It reflects the class teaching that "there is huge variability by distro" and provides both Ubuntu and CentOS perspectives. By combining system information, network configuration, service status, and connectivity testing, the script enables comprehensive network troubleshooting on Linux systems.

The script's organization around the TCP/IP model aligns with the assignment's emphasis that "you can troubleshoot going through each layer." Each section maps to a specific layer or aspect of network functionality.

---

**References:**

1. Linux Foundation - Networking Concepts
2. Red Hat Documentation - RHEL 9 Networking Configuration
3. Debian Wiki - Network Configuration
4. Ubuntu Manpage Repository - NetworkManager, Netplan, systemd-resolved
5. CIS245 Week 5 PowerPoint - Linux Administration Networking
6. CIS245 Class Video - Network Configuration and Troubleshooting
7. IETF RFC 1122 - Requirements for Internet Hosts
8. RFC 1918 - Private Internet Addresses

---

**Document Approval:**
- [ ] Review complete
- [ ] All commands tested
- [ ] Script functionality verified
- [ ] Output format meets requirements
