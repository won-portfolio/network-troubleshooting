#!/bin/bash

################################################################################
# NETWORK INFORMATION DUMP SCRIPT
# Purpose: Capture comprehensive network configuration and system info
# Output: Console display + timestamped file
# Usage: ./network_info_dump.sh
#
# This script gathers:
# - System information (hostname, OS version, kernel)
# - Network interface configuration (IP, MAC, status)
# - Routing information (default routes, routing table)
# - DNS configuration (nameservers, resolution status)
# - Network services status (NetworkManager, systemd-networkd, systemd-resolved)
# - Network statistics (listening ports, connections)
# - Installed network tools (net-tools, iproute2, etc.)
#
# Author: [YOUR NAME]
# Date Created: [DATE]
################################################################################

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current date/time for filename
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
USERNAME=$(whoami)
HOSTNAME=$(hostname)

# Create output filename with date, username, and purpose
OUTPUT_FILE="network_dump_${TIMESTAMP}_${USERNAME}_${HOSTNAME}.txt"

# Ensure output directory exists
OUTPUT_DIR="./network_dumps"
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILE"

# Function to print section header
print_header() {
    local header=$1
    echo ""
    echo "================================================================================"
    echo "  $header"
    echo "================================================================================"
}

# Function to print with both console and file output
log_output() {
    echo -e "$@" | tee -a "$OUTPUT_PATH"
}

# Function to run command and log output
run_command() {
    local cmd=$1
    local description=$2
    
    echo -e "\n${BLUE}[Command]${NC} $cmd" | tee -a "$OUTPUT_PATH"
    echo -e "${BLUE}[Output]${NC}" | tee -a "$OUTPUT_PATH"
    eval "$cmd" 2>&1 | tee -a "$OUTPUT_PATH"
}

# Initialize output file with header
{
    echo "================================================================================"
    echo " NETWORK INFORMATION DUMP REPORT"
    echo "================================================================================"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "User: $USERNAME"
    echo "Hostname: $HOSTNAME"
    echo "Output File: $OUTPUT_FILE"
    echo "================================================================================"
} > "$OUTPUT_PATH"

echo -e "${GREEN}=== NETWORK INFORMATION DUMP SCRIPT ===${NC}"
echo -e "${GREEN}Output will be saved to: ${YELLOW}$OUTPUT_PATH${NC}\n"

# ================================================================================
# SECTION 1: SYSTEM INFORMATION
# ================================================================================

print_header "SECTION 1: SYSTEM INFORMATION"

run_command "echo 'Hostname: '$(hostname)" "Hostname"
run_command "uname -a" "Kernel and System Info"
run_command "cat /etc/os-release" "OS Release Information"
run_command "lsb_release -a 2>/dev/null || echo 'lsb_release not available'" "LSB Release (Ubuntu)"
run_command "cat /etc/redhat-release 2>/dev/null || echo 'Not a Red Hat system'" "Red Hat Release (CentOS/RHEL)"
run_command "uptime" "System Uptime"
run_command "date" "Current Date and Time"

# ================================================================================
# SECTION 2: NETWORK INTERFACES
# ================================================================================

print_header "SECTION 2: NETWORK INTERFACES"

log_output "\n${BLUE}--- Using 'ip' command (Modern approach) ---${NC}"
run_command "ip addr show" "All Network Interfaces and IP Addresses"
run_command "ip link show" "Interface Status and MAC Addresses"
run_command "ip -s link show" "Interface Statistics (packets, errors, drops)"

log_output "\n${BLUE}--- Using 'ifconfig' command (Legacy, if available) ---${NC}"
run_command "ifconfig 2>/dev/null || echo 'ifconfig not installed or net-tools not available'" "Network Interfaces (Legacy)"

# ================================================================================
# SECTION 3: ROUTING CONFIGURATION
# ================================================================================

print_header "SECTION 3: ROUTING CONFIGURATION"

run_command "ip route show" "Routing Table (via ip command)"
run_command "route -n" "Routing Table (via route command - numeric IPs)"
run_command "ip route show all" "All Routes Including Hidden"
run_command "netstat -rn 2>/dev/null || echo 'netstat not available - use ss instead'" "Routing via netstat (legacy)"

# ================================================================================
# SECTION 4: DNS AND NAME RESOLUTION
# ================================================================================

print_header "SECTION 4: DNS AND NAME RESOLUTION"

run_command "cat /etc/resolv.conf" "DNS Configuration File (/etc/resolv.conf)"
run_command "cat /etc/hostname" "Hostname File (/etc/hostname)"
run_command "cat /etc/hosts" "Hosts File (/etc/hosts - static mappings)"
run_command "resolvectl status 2>/dev/null || echo 'resolvectl not available'" "systemd-resolved Status"
run_command "systemctl status systemd-resolved 2>/dev/null | head -20 || echo 'systemd-resolved not active'" "systemd-resolved Service Status"

# ================================================================================
# SECTION 5: NETWORKMANAGER STATUS (for CentOS/RHEL/some Ubuntu)
# ================================================================================

print_header "SECTION 5: NETWORKMANAGER CONFIGURATION (if available)"

run_command "nmcli device show 2>/dev/null || echo 'NetworkManager not installed or not running'" "NetworkManager Device Information"
run_command "nmcli con show 2>/dev/null || echo 'NetworkManager not installed'" "NetworkManager Connection Profiles"
run_command "systemctl status NetworkManager 2>/dev/null | head -20 || echo 'NetworkManager not active'" "NetworkManager Service Status"
run_command "ls -la /etc/NetworkManager/system-connections/ 2>/dev/null || echo 'NetworkManager config directory not found'" "NetworkManager Configuration Files"

# ================================================================================
# SECTION 6: NETPLAN CONFIGURATION (for Ubuntu)
# ================================================================================

print_header "SECTION 6: NETPLAN CONFIGURATION (if available - Ubuntu)"

run_command "ls -la /etc/netplan/ 2>/dev/null || echo 'Netplan not found (not Ubuntu or configured)'" "Netplan Configuration Directory"
run_command "cat /etc/netplan/*.yaml 2>/dev/null || echo 'No Netplan YAML files found'" "Netplan Configuration Files"
run_command "systemctl status systemd-networkd 2>/dev/null | head -20 || echo 'systemd-networkd not active'" "systemd-networkd Service Status"

# ================================================================================
# SECTION 7: NETWORK SERVICES STATUS
# ================================================================================

print_header "SECTION 7: NETWORK SERVICES STATUS"

run_command "systemctl status networking 2>/dev/null || echo 'networking service not found'" "Networking Service Status (Debian/Ubuntu)"
run_command "systemctl status network 2>/dev/null || echo 'network service not found'" "Network Service Status (older Red Hat)"
run_command "systemctl list-units --type=service | grep -i network" "All Network-Related Services"

# ================================================================================
# SECTION 8: LISTENING PORTS AND CONNECTIONS
# ================================================================================

print_header "SECTION 8: LISTENING PORTS AND ACTIVE CONNECTIONS"

log_output "\n${BLUE}--- Using 'ss' command (Modern approach) ---${NC}"
run_command "ss -tuln" "All Listening TCP and UDP Ports (numeric)"
run_command "ss -tuan" "All TCP and UDP Connections (numeric)"
run_command "ss -l" "All Listening Sockets"

log_output "\n${BLUE}--- Using 'netstat' command (Legacy, if available) ---${NC}"
run_command "netstat -tuln 2>/dev/null || echo 'netstat not available (use ss instead)'" "Listening Ports (Legacy)"
run_command "netstat -an 2>/dev/null | head -30 || echo 'netstat not available'" "All Connections - First 30 lines (Legacy)"

# ================================================================================
# SECTION 9: ARP TABLE (Address Resolution Protocol)
# ================================================================================

print_header "SECTION 9: ARP TABLE - KNOWN NETWORK NEIGHBORS"

run_command "arp -n 2>/dev/null || ip neighbor show" "ARP Table (Known MAC-to-IP Mappings)"
run_command "ip neighbor show" "IP Neighbors (modern equivalent of ARP)"

# ================================================================================
# SECTION 10: INSTALLED NETWORK TOOLS
# ================================================================================

print_header "SECTION 10: INSTALLED NETWORK TOOLS AND PACKAGES"

# Check if it's Ubuntu/Debian or CentOS/RHEL
if command -v apt &> /dev/null; then
    log_output "\n${BLUE}--- System is Debian/Ubuntu based ---${NC}"
    run_command "apt list --installed 2>/dev/null | grep -E 'net-tools|iproute|iputils|traceroute|dig|curl|wget|tcpdump|ethtool'" "Installed Network Packages"
    run_command "dpkg -l | grep -E 'net-tools|iproute|iputils'" "Network Packages Details (dpkg)"
elif command -v dnf &> /dev/null; then
    log_output "\n${BLUE}--- System is RHEL/CentOS/Fedora based (DNF) ---${NC}"
    run_command "dnf list installed 2>/dev/null | grep -E 'net-tools|iproute|iputils|traceroute|bind-utils|curl|wget|tcpdump|ethtool'" "Installed Network Packages"
    run_command "rpm -qa | grep -E 'net-tools|iproute|iputils'" "Network Packages Details (rpm)"
elif command -v yum &> /dev/null; then
    log_output "\n${BLUE}--- System is RHEL/CentOS based (YUM) ---${NC}"
    run_command "yum list installed 2>/dev/null | grep -E 'net-tools|iproute|iputils|traceroute|bind-utils'" "Installed Network Packages"
fi

# ================================================================================
# SECTION 11: NETWORK TOOL VERSIONS
# ================================================================================

print_header "SECTION 11: NETWORK TOOL VERSIONS"

run_command "ip --version" "IP Command Version"
run_command "ss --version 2>/dev/null || echo 'ss version check not available'" "SS Command Version"
run_command "ifconfig --version 2>/dev/null || echo 'ifconfig not available or version check failed'" "ifconfig Version"
run_command "route --version 2>/dev/null || echo 'route version check failed'" "Route Command Version"
run_command "arp --version 2>/dev/null || echo 'arp version check failed'" "ARP Command Version"
run_command "ping -V 2>&1 | head -1" "Ping Version"
run_command "traceroute --version 2>/dev/null || tracepath --help 2>&1 | head -1" "Traceroute/Tracepath Version"

# ================================================================================
# SECTION 12: DNS TESTING
# ================================================================================

print_header "SECTION 12: DNS TESTING AND RESOLUTION"

run_command "nslookup google.com 2>/dev/null || echo 'nslookup not available - install bind-utils or dnsutils'" "DNS Lookup: google.com (nslookup)"
run_command "dig google.com 2>/dev/null || echo 'dig not available'" "DNS Lookup: google.com (dig - detailed)"
run_command "host google.com 2>/dev/null || echo 'host command not available'" "DNS Lookup: google.com (host)"
run_command "getent hosts localhost" "Local Host Entry Resolution"

# ================================================================================
# SECTION 13: NETWORK CONNECTIVITY TESTS
# ================================================================================

print_header "SECTION 13: NETWORK CONNECTIVITY TESTS"

log_output "\n${YELLOW}[Note: These tests require network connectivity]${NC}"
run_command "ping -c 3 8.8.8.8" "Ping Google DNS (8.8.8.8) - 3 packets"
run_command "ping -c 3 google.com" "Ping google.com - 3 packets"
run_command "tracepath google.com 2>/dev/null || echo 'tracepath not available'" "Trace Path to google.com"
run_command "curl -s -w 'HTTP Status: %{http_code}\n' -o /dev/null https://www.google.com || echo 'curl not available or connection failed'" "HTTP Connectivity Test (Google)"

# ================================================================================
# SECTION 14: INTERFACE DETAILS (ethtool if available)
# ================================================================================

print_header "SECTION 14: INTERFACE DETAILS (ethtool - if available)"

# Get first active interface
ACTIVE_INT=$(ip link show | grep "state UP" | awk '{print $2}' | sed 's/:$//' | head -1)

if [ -n "$ACTIVE_INT" ]; then
    run_command "ethtool $ACTIVE_INT 2>/dev/null || echo 'ethtool not available or not installed'" "Interface Details for $ACTIVE_INT (ethtool)"
    run_command "ethtool -i $ACTIVE_INT 2>/dev/null || echo 'ethtool driver info not available'" "Driver Information for $ACTIVE_INT"
    run_command "ethtool -S $ACTIVE_INT 2>/dev/null | head -20 || echo 'ethtool statistics not available'" "Statistics for $ACTIVE_INT (first 20 lines)"
else
    log_output "\n${RED}No active interfaces found to check with ethtool${NC}"
fi

# ================================================================================
# SECTION 15: FIREWALL STATUS
# ================================================================================

print_header "SECTION 15: FIREWALL STATUS"

run_command "systemctl status firewalld 2>/dev/null | head -15 || echo 'firewalld not found'" "Firewall (firewalld) Status - CentOS/RHEL"
run_command "firewall-cmd --list-all 2>/dev/null || echo 'firewall-cmd not available'" "Firewall Rules (firewalld)"
run_command "systemctl status ufw 2>/dev/null | head -15 || echo 'UFW not found'" "Firewall (UFW) Status - Ubuntu"
run_command "sudo iptables -L -n 2>/dev/null || echo 'iptables not available or requires sudo'" "iptables Rules (if iptables is in use)"

# ================================================================================
# COMPLETION
# ================================================================================

print_header "REPORT GENERATION COMPLETE"

log_output "\n${GREEN}✓ Network information dump completed successfully${NC}"
log_output "Output file: ${YELLOW}$OUTPUT_PATH${NC}"
log_output "File size: $(du -h "$OUTPUT_PATH" | awk '{print $1}')"
log_output "\n${BLUE}Commands used in this script:${NC}"
log_output "- ip: Modern network interface configuration"
log_output "- ifconfig: Legacy interface configuration (net-tools)"
log_output "- route/netstat: Legacy routing information"
log_output "- ss: Modern socket statistics"
log_output "- nmcli: NetworkManager command-line interface"
log_output "- systemctl: Service status checks"
log_output "- resolvectl: DNS configuration status"
log_output "- arp/ip neighbor: Address resolution"
log_output "- ping/tracepath: Connectivity testing"
log_output "- dig/nslookup: DNS resolution testing"
log_output "- ethtool: Detailed interface information"
log_output "- firewall-cmd/iptables: Firewall status"

log_output "\n${BLUE}To view the full report:${NC}"
log_output "  cat $OUTPUT_PATH"
log_output "  less $OUTPUT_PATH"
log_output "  grep 'keyword' $OUTPUT_PATH  (search for specific info)"

log_output "\n${BLUE}To copy to another machine for analysis:${NC}"
log_output "  scp $OUTPUT_PATH user@remote:/path/to/save/"

log_output "\n${GREEN}End of Report${NC}"

# Also print summary to console
echo -e "\n${GREEN}=== SUMMARY ===${NC}"
echo -e "Report saved to: ${YELLOW}$OUTPUT_PATH${NC}"
echo -e "File location: ${YELLOW}./network_dumps/${NC}"
echo ""
echo "The output file contains:"
echo "  • System information (OS, kernel, hostname)"
echo "  • Network interface configurations"
echo "  • Routing tables and default gateways"
echo "  • DNS nameserver configuration"
echo "  • NetworkManager/Netplan/systemd-networkd settings"
echo "  • Listening ports and active connections"
echo "  • ARP table (network neighbors)"
echo "  • Installed network tool versions"
echo "  • DNS and connectivity test results"
echo "  • Firewall status"
echo ""
echo -e "${GREEN}✓ Script execution completed successfully${NC}"
