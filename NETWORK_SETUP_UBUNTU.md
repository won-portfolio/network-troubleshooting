# Network Setup Documentation — Ubuntu Server
**Server:** Ubuntu 24.04 LTS (or specify your version)  
**Date Documentation Created:** [FILL IN DATE]  
**Last Updated:** [FILL IN DATE]  
**Documented By:** [YOUR NAME]

---

## 1. Current Network Configuration Overview

### How Ubuntu Networking Works (Default Behavior)

Ubuntu uses **Netplan** (Ubuntu 18.04+) or **NetworkManager** (Desktop) combined with **systemd-networkd** (Server). On server installations:

- **Primary tool:** Netplan (configuration) + systemd-networkd (execution)
- **Config location:** `/etc/netplan/` (YAML files)
- **DNS management:** systemd-resolved (reads from Netplan config)
- **Interface management:** Can be manual via `/etc/network/interfaces` (legacy, still supported)
- **Service:** `systemctl status systemd-networkd` and `systemctl status systemd-resolved`

By default:
- DHCP is typically enabled (auto IP assignment)
- Interfaces are brought up at boot via Netplan
- DNS servers are assigned via DHCP or configured manually in Netplan

---

## 2. Network Information Location & Files

### Key Configuration Files

| File/Location | Purpose | Default/Current Value |
|---|---|---|
| `/etc/netplan/*.yaml` | Network interface configuration (Netplan) | [RUN: `ls -la /etc/netplan/`] |
| `/etc/resolv.conf` | DNS nameserver list (symlink to systemd-resolved) | [RUN: `cat /etc/resolv.conf`] |
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

# Show hostname
hostname
hostnamectl status

# Check interface statistics
ip -s link show

# Show all network connections and listening ports
ss -tuln

# Check DHCP lease (if DHCP is enabled)
systemctl status systemd-networkd
journalctl -u systemd-networkd -n 50
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

**Interface Details:**
- **Primary Interface Name:** [e.g., eth0, ens33, enp0s3]
- **IPv4 Address:** [e.g., 192.168.x.x/24]
- **IPv6 Address:** [if applicable]
- **MAC Address:** [Hardware address]
- **Status:** [UP/DOWN]

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

## 4. Network Interface Configuration (Netplan)

**View current Netplan configuration:**
```bash
cat /etc/netplan/00-installer-config.yaml
```
(Or whatever file exists in `/etc/netplan/`)

**Output:**
```
[PASTE OUTPUT HERE]
```

### Is This Server Using Static or Dynamic IP?

- [ ] **Dynamic (DHCP)** — IP assigned automatically
- [ ] **Static** — IP manually configured

**If Static:** What is the configured IP address range?
```
[FILL IN]
```

---

## 5. Installed Networking Tools & Packages

### net-tools Package

**Installation Date:** [FILL IN]

**Installed via:**
```bash
sudo apt update
sudo apt install net-tools -y
```

**Commands included in net-tools:**
- `ifconfig` — Display/configure network interfaces (legacy, still widely used)
- `arp` — Address Resolution Protocol tool
- `route` — Display/configure routing table
- `netstat` — Network statistics (legacy; modern replacement: `ss`)
- `hostname` — Display/set hostname
- `ifup/ifdown` — Bring interfaces up/down

**Verify installation:**
```bash
which ifconfig
ifconfig --version
apt list --installed | grep net-tools
```

**Output:**
```
[PASTE OUTPUT HERE]
```

---

### Other Installed Networking Tools

**Run to see all network-related packages:**
```bash
apt list --installed | grep -i 'net\|dns\|resolv\|network'
```

**Output:**
```
[PASTE OUTPUT HERE]
```

| Tool | Install Date | Purpose |
|---|---|---|
| iproute2 | [System default] | Modern IP/routing/interface management (`ip`, `ss`, `tc`) |
| iputils-ping | [System default] | ICMP ping command |
| systemd-resolved | [System default] | DNS resolution service |
| curl/wget | [If installed] | HTTP/HTTPS request tools (useful for testing connectivity) |
| traceroute | [If installed] | Trace network path to a destination |
| dig/dnsutils | [If installed] | DNS lookup tools |
| tcpdump | [If installed] | Network packet capture |

---

## 6. Network Service Status

**Check if systemd-networkd is running:**
```bash
sudo systemctl status systemd-networkd
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

---

## 7. Custom Modifications & Changes Made

**Date of Change:** [FILL IN]

**What was changed:** [Describe any modifications to default network config]

**File modified:** [Which file]

**Change details:**
```
[Describe what was changed and why]
```

**Command used:**
```bash
[Command used to make the change]
```

---

## 8. Troubleshooting Reference — Ubuntu Networking

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

# DNS troubleshooting
resolvectl status               # Current DNS config
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

# Edit network config (requires sudo)
sudo nano /etc/netplan/00-installer-config.yaml   # Edit Netplan config
sudo netplan apply             # Apply changes
```

---

## 9. Network Testing Log

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
ip link show
```
Result: [All interfaces UP? Yes/No]

---

## 10. Additional Notes

[Any additional information, changes, or observations about your network setup]

---

**Documentation Review:**
- [ ] All files and commands tested and verified
- [ ] Screenshots taken of key outputs
- [ ] All configuration files reviewed
- [ ] Network connectivity confirmed
