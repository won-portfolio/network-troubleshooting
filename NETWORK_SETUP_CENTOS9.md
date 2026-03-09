# Network Setup Documentation — CentOS/RHEL 9 Server
**Server:** CentOS 9 Stream (or RHEL 9)  
**Date Documentation Created:** [FILL IN DATE]  
**Last Updated:** [FILL IN DATE]  
**Documented By:** [YOUR NAME]

---

## 1. Current Network Configuration Overview

### How CentOS 9 Networking Works (Default Behavior)

CentOS 9 uses **NetworkManager** as the default networking service, combined with **systemd-networkd**. On servers:

- **Primary tool:** NetworkManager (service) + nmcli (command-line interface)
- **Config location:** `/etc/NetworkManager/system-connections/` (connection profiles in YAML/INI format)
- **Legacy config location:** `/etc/sysconfig/network-scripts/ifcfg-*` (still supported but being phased out)
- **DNS management:** NetworkManager handles DNS via systemd-resolved
- **Service:** `systemctl status NetworkManager`

By default:
- DHCP is typically enabled (auto IP assignment)
- Interfaces are managed by NetworkManager at boot
- DNS servers are assigned via DHCP or configured via connection profiles

**Key difference from Red Hat 7:** RHEL 9 moved from network scripts to NetworkManager as the primary method. Legacy scripts in `/etc/init.d/network` no longer exist.

---

## 2. Network Information Location & Files

### Key Configuration Files

| File/Location | Purpose | Default/Current Value |
|---|---|---|
| `/etc/NetworkManager/system-connections/` | Connection profiles (replaces old network scripts) | [RUN: `ls -la /etc/NetworkManager/system-connections/`] |
| `/etc/sysconfig/network-scripts/ifcfg-*` | Legacy network interface config (still works, being phased out) | [RUN: `ls -la /etc/sysconfig/network-scripts/` \|] |
| `/etc/sysconfig/network` | Global network settings | [RUN: `cat /etc/sysconfig/network`] |
| `/etc/resolv.conf` | DNS nameserver list (managed by NetworkManager/systemd-resolved) | [RUN: `cat /etc/resolv.conf`] |
| `/etc/hostname` | Machine hostname | [RUN: `cat /etc/hostname`] |
| `/etc/hosts` | Static hostname-to-IP mappings | [RUN: `cat /etc/hosts`] |
| `/sys/class/net/` | Runtime network interface info | [RUN: `ls /sys/class/net/`] |

### How to Find All Network Information

```bash
# Display all active network interfaces and IPs
ip addr show

# Show all network interfaces (up and down)
ip link show

# Display default routes
ip route show

# Show DNS servers (systemd-resolved)
resolvectl status

# NetworkManager specific commands
nmcli device show                  # All device info from NetworkManager
nmcli con show                     # All connection profiles
nmcli device status                # Quick interface status

# Show hostname
hostname
hostnamectl status

# Check interface statistics
ip -s link show

# Show all network connections and listening ports
ss -tuln

# View active connection details
nmcli connection show --active
```

---

## 3. Current Network Configuration Details

### Network Interfaces

**Run this command and fill in the results:**
```bash
ip addr show
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Also check via NetworkManager:**
```bash
nmcli device show
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Interface Details:**
- **Primary Interface Name:** [e.g., eth0, ens33, enp0s3]
- **IPv4 Address:** [e.g., 192.168.x.x/24]
- **IPv6 Address:** [if applicable]
- **MAC Address:** [Hardware address]
- **Status:** [UP/DOWN]
- **Connection Name (NetworkManager):** [From `nmcli con show`]

---

### DNS Configuration

**Run this command:**
```bash
cat /etc/resolv.conf
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Also check systemd-resolved:**
```bash
resolvectl status
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Check NetworkManager DNS settings:**
```bash
nmcli device show | grep IP4.DNS
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Current DNS Servers:**
- Primary (Nameserver 1): [e.g., 8.8.8.8]
- Secondary (Nameserver 2): [e.g., 8.8.4.4]
- Domain Search List: [if any]

---

### Routing Information

**Run this command:**
```bash
ip route show
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Default Gateway:** [e.g., 192.168.1.1]

**Run this for more detail:**
```bash
route -n
```

**Output:**
```
[PASTE OUTPUT HERE]
```

---

### Hostname Configuration

**Run:**
```bash
hostname
hostnamectl status
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Current Hostname:** [Your server's hostname]

---

## 4. Network Connection Profiles (NetworkManager)

### View Current Connection Profiles

**Run:**
```bash
nmcli con show
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**View active connections:**
```bash
nmcli con show --active
```

**Output:**
```
[PASTE OUTPUT HERE]
```

### View Connection Profile Details

**For each connection, run:**
```bash
nmcli con show [CONNECTION_NAME]
```

**Output:**
```
[PASTE OUTPUT HERE]
```

### Legacy Network Scripts (if still present)

**Check if legacy ifcfg files exist:**
```bash
ls -la /etc/sysconfig/network-scripts/ifcfg-*
```

**Output:**
```
[PASTE OUTPUT HERE]
```

---

## 5. Is This Server Using Static or Dynamic IP?

**Check the connection type:**
```bash
nmcli con show [CONNECTION_NAME] | grep ipv4.method
```

- [ ] **Dynamic (DHCP)** — ipv4.method shows "auto"
- [ ] **Static** — ipv4.method shows "manual"

**If Static:** What is the configured IP address?
```bash
nmcli con show [CONNECTION_NAME] | grep "IP4.ADDRESS\|ip4.addresses"
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**If Dynamic:** What DHCP server assigns the IP?
```bash
journalctl -u NetworkManager -n 20
```

**Output:**
```
[PASTE OUTPUT HERE]
```

---

## 6. Installed Networking Tools & Packages

### net-tools Package

**Installation Date:** [FILL IN]

**Installed via:**
```bash
sudo dnf install net-tools -y
```

**Commands included in net-tools:**
- `ifconfig` — Display/configure network interfaces (legacy, still widely used)
- `arp` — Address Resolution Protocol tool
- `route` — Display/configure routing table
- `netstat` — Network statistics (legacy; modern replacement: `ss`)
- `hostname` — Display/set hostname

**Verify installation:**
```bash
which ifconfig
ifconfig --version
dnf list installed | grep net-tools
```

**Output:**
```
[PASTE OUTPUT HERE]
```

---

### Other Installed Networking Tools

**Run to see all network-related packages:**
```bash
dnf list installed | grep -i 'net\|dns\|network\|nmcli'
```

**Output:**
```
[PASTE OUTPUT HERE]
```

| Tool | Install Date | Purpose |
|---|---|---|
| NetworkManager | [System default] | Network service (primary) |
| iproute | [System default] | Modern IP/routing/interface management (`ip`, `ss`, `tc`) |
| iputils | [System default] | ICMP ping command |
| systemd-resolved | [System default] | DNS resolution service |
| curl/wget | [If installed] | HTTP/HTTPS request tools (useful for testing connectivity) |
| traceroute | [If installed] | Trace network path to a destination |
| bind-utils (dig, nslookup) | [If installed] | DNS lookup tools |
| tcpdump | [If installed] | Network packet capture |

---

## 7. Network Service Status

**Check if NetworkManager is running:**
```bash
sudo systemctl status NetworkManager
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Check if systemd-resolved is running:**
```bash
sudo systemctl status systemd-resolved
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Check network interface status:**
```bash
ip link show
```

**Output:**
```
[PASTE OUTPUT HERE]
```

**Check all NetworkManager devices:**
```bash
nmcli device
```

**Output:**
```
[PASTE OUTPUT HERE]
```

---

## 8. Custom Modifications & Changes Made

**Date of Change:** [FILL IN]

**What was changed:** [Describe any modifications to default network config]

**File/Connection modified:** [Which file or connection name]

**Change details:**
```
[Describe what was changed and why]
```

**Command used:**
```bash
[Command used to make the change]
# Example: nmcli con mod [connection-name] ipv4.method manual ipv4.addresses 192.168.1.100/24
# Then: nmcli con up [connection-name]
```

---

## 9. Troubleshooting Reference — CentOS 9 Networking

### Quick Troubleshooting Steps (TCP/IP Model)

| Layer | Check | Command |
|---|---|---|
| **Physical/Link** | Is cable plugged in? Interface up? | `ip link show` or `ifconfig` |
| **Data Link** | Do we have a MAC address? | `ip addr show` or `ifconfig` |
| **Network** | Do we have an IP? Is DNS working? | `ip addr show` + `nslookup google.com` |
| **Transport** | Is the port open? | `ss -tuln` |
| **Application** | Is the service running? | `systemctl status [service]` |

### Common Commands Quick Reference

```bash
# Basic network info
ip addr show                    # All interfaces and IPs
ip link show                    # Interface status
ip route show                   # Routing table
hostname                        # Show hostname

# NetworkManager specific
nmcli device show              # All device details
nmcli con show                 # All connections
nmcli con show --active        # Active connections only

# DNS troubleshooting
resolvectl status              # Current DNS config
nslookup google.com            # DNS lookup
dig google.com                 # Detailed DNS lookup

# Connectivity tests
ping -c 4 8.8.8.8              # Test connectivity to Google DNS
tracepath 8.8.8.8              # Trace route to destination
curl -I https://google.com     # Test HTTP connectivity

# Port/service checks
ss -tuln                        # All listening ports
sudo systemctl status ssh      # Check SSH service
netstat -tuln                  # Alternative to ss (legacy)

# Modify network (examples)
sudo nmcli con mod [name] ipv4.method auto              # Set to DHCP
sudo nmcli con mod [name] ipv4.method manual            # Set to static
sudo nmcli con mod [name] ipv4.addresses 192.168.1.100/24  # Set static IP
sudo nmcli con up [name]                                # Activate connection
sudo nmcli con down [name]                              # Deactivate connection
```

---

## 10. Network Testing Log

**Test Date:** [FILL IN]

**Test 1: Ping Gateway**
```bash
ping -c 4 [YOUR_GATEWAY_IP]
```
Result: [PASS/FAIL]

**Test 2: Ping DNS**
```bash
ping -c 4 8.8.8.8
```
Result: [PASS/FAIL]

**Test 3: DNS Resolution**
```bash
nslookup google.com
```
Result: [PASS/FAIL]

**Test 4: Interface Status**
```bash
nmcli device
```
Result: [All connected? Yes/No]

---

## 11. Additional Notes

[Any additional information, changes, or observations about your network setup]

---

**Documentation Review:**
- [ ] All files and commands tested and verified
- [ ] Screenshots taken of key outputs
- [ ] All configuration profiles reviewed
- [ ] Network connectivity confirmed
