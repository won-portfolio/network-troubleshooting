#!/bin/bash

################################################################################
# NETWORK TROUBLESHOOTING GUIDE - INTERACTIVE SCRIPT
# Purpose: Provide server-specific network troubleshooting guidance
# Usage: ./network_troubleshoot.sh
#
# This script presents an interactive menu system that:
# 1. Asks which server type (Ubuntu or CentOS 9)
# 2. Provides troubleshooting suggestions based on server
# 3. Covers: no internet, static IP setup, DNS checks, traceroute
#
# Target: Someone with technical knowledge but not expert-level
#
# Author: [YOUR NAME]
# Date Created: [DATE]
################################################################################

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variable to store server type
SERVER_TYPE=""

################################################################################
# FUNCTION: Clear screen with header
################################################################################
show_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}             ${BLUE}NETWORK TROUBLESHOOTING GUIDE - INTERACTIVE${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}         For Ubuntu & CentOS 9 Linux Servers                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

################################################################################
# FUNCTION: Select server type
################################################################################
select_server_type() {
    show_header
    
    echo -e "${YELLOW}Which server type are you troubleshooting?${NC}\n"
    echo "  1) Ubuntu (24.04 or similar)"
    echo "  2) CentOS 9 Stream / RHEL 9"
    echo "  3) Exit\n"
    
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            SERVER_TYPE="ubuntu"
            return 0
            ;;
        2)
            SERVER_TYPE="centos"
            return 0
            ;;
        3)
            echo -e "${GREEN}Exiting troubleshooting guide. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            sleep 2
            select_server_type
            ;;
    esac
}

################################################################################
# FUNCTION: Main menu
################################################################################
show_main_menu() {
    show_header
    
    echo -e "${YELLOW}Selected Server: ${GREEN}$SERVER_TYPE${NC}\n"
    echo "Choose a troubleshooting scenario:\n"
    echo "  1) No Internet Connectivity"
    echo "  2) Slow or Intermittent Connection"
    echo "  3) Configure Static IP Address"
    echo "  4) DNS Resolution Issues"
    echo "  5) Trace Network Path to Website"
    echo "  6) Check Listening Ports & Services"
    echo "  7) View All Network Configuration"
    echo "  8) Change Server Type"
    echo "  9) Exit\n"
    
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1) troubleshoot_no_internet ;;
        2) troubleshoot_slow_connection ;;
        3) configure_static_ip ;;
        4) troubleshoot_dns ;;
        5) trace_network_path ;;
        6) check_services ;;
        7) view_network_config ;;
        8) select_server_type; show_main_menu ;;
        9) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) 
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            sleep 2
            show_main_menu
            ;;
    esac
}

################################################################################
# FUNCTION: No Internet Connectivity Troubleshooting
################################################################################
troubleshoot_no_internet() {
    show_header
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}TROUBLESHOOTING: NO INTERNET CONNECTIVITY${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${CYAN}Using TCP/IP Model - Start at Physical layer and work up:${NC}\n"
    
    # PHYSICAL/LINK LAYER
    echo -e "${GREEN}STEP 1: Physical/Link Layer - Is the interface connected?${NC}"
    echo "Check if network interface is UP:\n"
    
    if [ "$SERVER_TYPE" = "ubuntu" ]; then
        echo -e "${BLUE}Command:${NC}"
        echo "  ip link show"
        echo ""
        echo -e "${YELLOW}What to look for:${NC}"
        echo "  • Find your interface (eth0, ens33, enp0s3, etc.)"
        echo "  • Look for 'state UP' (green indicator)"
        echo "  • If 'state DOWN', try: ip link set [interface] up"
        echo ""
        echo -e "${BLUE}On Ubuntu, bring up interface:${NC}"
        echo "  sudo ip link set [interface-name] up"
        echo "  or:"
        echo "  sudo ifup [interface-name]"
    else
        echo -e "${BLUE}Command:${NC}"
        echo "  ip link show"
        echo "  OR"
        echo "  nmcli device"
        echo ""
        echo -e "${YELLOW}What to look for:${NC}"
        echo "  • Find your interface in the list"
        echo "  • Look for 'connected' status"
        echo "  • If disconnected, bring it up:"
        echo ""
        echo -e "${BLUE}On CentOS 9, bring up interface:${NC}"
        echo "  nmcli device connect [interface-name]"
        echo "  or:"
        echo "  nmcli con up [connection-name]"
        echo "  or:"
        echo "  sudo ip link set [interface-name] up"
    fi
    
    echo ""
    echo -e "${GREEN}STEP 2: Network Layer - Do you have an IP address?${NC}"
    echo "Check if interface has been assigned an IP:\n"
    echo -e "${BLUE}Command:${NC}"
    echo "  ip addr show"
    echo ""
    echo -e "${YELLOW}What to look for:${NC}"
    echo "  • inet 192.168.x.x/24 (you need an IPv4 address)"
    echo "  • If no address, you have a DHCP problem:"
    echo ""
    
    if [ "$SERVER_TYPE" = "ubuntu" ]; then
        echo -e "${BLUE}On Ubuntu - Request DHCP lease:${NC}"
        echo "  sudo dhclient -v [interface-name]"
        echo "  OR (newer systems):"
        echo "  sudo netplan apply"
    else
        echo -e "${BLUE}On CentOS 9 - Request IP from DHCP:${NC}"
        echo "  nmcli con down [connection-name]"
        echo "  nmcli con up [connection-name]"
        echo "  OR:"
        echo "  sudo dhclient -v [interface-name]"
    fi
    
    echo ""
    echo -e "${GREEN}STEP 3: Network Layer - Can you reach the gateway?${NC}"
    echo "Ping the default gateway:\n"
    echo -e "${BLUE}Find gateway:${NC}"
    echo "  ip route show"
    echo "  (Look for 'default via' line)\n"
    echo -e "${BLUE}Ping gateway:${NC}"
    echo "  ping -c 3 [GATEWAY_IP]"
    echo ""
    echo -e "${YELLOW}If ping fails:${NC}"
    echo "  • Check if gateway IP is correct"
    echo "  • Check if interface is connected to correct network"
    echo "  • Try: sudo ip route add default via [GATEWAY_IP]"
    
    echo ""
    echo -e "${GREEN}STEP 4: Network Layer - Is DNS working?${NC}"
    echo "Test DNS resolution:\n"
    echo -e "${BLUE}Try:${NC}"
    echo "  ping -c 3 8.8.8.8  (ping IP directly - tests basic connectivity)"
    echo "  ping -c 3 google.com  (ping hostname - tests DNS)"
    echo ""
    echo -e "${YELLOW}If IP ping works but hostname doesn't:${NC}"
    echo "  DNS problem - see 'DNS Resolution Issues' in main menu"
    
    echo ""
    echo -e "${GREEN}STEP 5: Common Issues Checklist:${NC}"
    echo -e "  ${RED}☐${NC} Cable not plugged in? (Check physical cable)"
    echo -e "  ${RED}☐${NC} Interface DOWN? (Use 'ip link set [int] up')"
    echo -e "  ${RED}☐${NC} No IP address? (Restart NetworkManager/netplan)"
    echo -e "  ${RED}☐${NC} Can't reach gateway? (Check routing table, firewall)"
    echo -e "  ${RED}☐${NC} Can't resolve DNS? (Check /etc/resolv.conf)"
    echo -e "  ${RED}☐${NC} Firewall blocking? (Check firewalld/iptables)"
    
    echo ""
    read -p "Press Enter to return to main menu..."
    show_main_menu
}

################################################################################
# FUNCTION: Slow Connection Troubleshooting
################################################################################
troubleshoot_slow_connection() {
    show_header
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}TROUBLESHOOTING: SLOW OR INTERMITTENT CONNECTIONS${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${GREEN}Possible causes and how to diagnose:${NC}\n"
    
    echo -e "${CYAN}1. HIGH LATENCY or PACKET LOSS${NC}"
    echo "Check ping response times and packet loss:\n"
    echo -e "${BLUE}Command:${NC}"
    echo "  ping -c 20 8.8.8.8"
    echo ""
    echo -e "${YELLOW}Look for:${NC}"
    echo "  • Excessive latency (> 100ms usually indicates a problem)"
    echo "  • Packet loss (0% is normal, >1% is concerning)"
    echo "  • Use tracepath to see where latency occurs:"
    echo "    tracepath google.com"
    
    echo ""
    echo -e "${CYAN}2. INTERFACE ERRORS or DROPPED PACKETS${NC}"
    echo "Check network interface statistics:\n"
    echo -e "${BLUE}Command:${NC}"
    echo "  ip -s link show"
    echo ""
    echo -e "${YELLOW}Look for:${NC}"
    echo "  • RX dropped: [Number of dropped receive packets]"
    echo "  • TX dropped: [Number of dropped transmit packets]"
    echo "  • errors: [Should be 0]"
    echo "  • If high, there may be hardware or driver issues"
    echo "  • Try: sudo ethtool -S [interface-name] | grep -i drop"
    
    echo ""
    echo -e "${CYAN}3. CONGESTED NETWORK or HIGH BANDWIDTH USE${NC}"
    echo "Check network traffic:\n"
    echo -e "${BLUE}Command:${NC}"
    echo "  ss -i  (socket statistics with info)"
    echo "  sudo nethogs  (if installed - shows per-process bandwidth)"
    echo ""
    echo -e "${YELLOW}Look for:${NC}"
    echo "  • Is another service consuming bandwidth?"
    echo "  • Are there many connections to the same host?"
    echo "  • Kill unnecessary services or connections"
    
    echo ""
    echo -e "${CYAN}4. DNS RESOLUTION SLOWNESS${NC}"
    echo "DNS lookups taking too long?\n"
    echo -e "${BLUE}Test DNS speed:${NC}"
    echo "  time nslookup google.com"
    echo ""
    echo -e "${YELLOW}If slow:${NC}"
    echo "  • Check DNS servers: cat /etc/resolv.conf"
    echo "  • Try Google DNS: nameserver 8.8.8.8"
    echo "  • Or Cloudflare: nameserver 1.1.1.1"
    
    echo ""
    echo -e "${CYAN}5. FIREWALL RATE LIMITING${NC}"
    echo "Check if firewall is limiting traffic:\n"
    
    if [ "$SERVER_TYPE" = "ubuntu" ]; then
        echo -e "${BLUE}On Ubuntu:${NC}"
        echo "  sudo ufw status verbose"
        echo "  sudo iptables -L -n -v | grep DROP"
    else
        echo -e "${BLUE}On CentOS 9:${NC}"
        echo "  sudo firewall-cmd --list-all"
        echo "  sudo firewall-cmd --get-rules-for-target DROP 2>/dev/null"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
    show_main_menu
}

################################################################################
# FUNCTION: Configure Static IP
################################################################################
configure_static_ip() {
    show_header
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}CONFIGURING STATIC IP ADDRESS${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}First, gather information about your current network:${NC}\n"
    echo -e "${BLUE}Run these commands to find current settings:${NC}"
    echo "  ip addr show           (your current IP)"
    echo "  ip route show          (default gateway)"
    echo "  cat /etc/resolv.conf   (DNS nameservers)\n"
    
    if [ "$SERVER_TYPE" = "ubuntu" ]; then
        echo -e "${CYAN}UBUNTU - Using Netplan${NC}\n"
        
        echo -e "${BLUE}Step 1: Identify your interface name${NC}"
        echo "  ip link show"
        echo "  (Look for something like eth0, ens33, enp0s3)"
        echo ""
        
        echo -e "${BLUE}Step 2: Edit the Netplan configuration file${NC}"
        echo "  sudo nano /etc/netplan/00-installer-config.yaml"
        echo ""
        
        echo -e "${BLUE}Step 3: Replace DHCP with static configuration${NC}"
        echo "  Replace:"
        echo "    dhcp4: true"
        echo ""
        echo "  With:"
        echo "    dhcp4: no"
        echo "    addresses:"
        echo "      - 192.168.1.100/24"
        echo "    routes:"
        echo "      - to: default"
        echo "        via: 192.168.1.1"
        echo "    nameservers:"
        echo "      addresses:"
        echo "        - 8.8.8.8"
        echo "        - 8.8.4.4"
        echo ""
        
        echo -e "${YELLOW}Example file:${NC}"
        echo "  network:"
        echo "    version: 2"
        echo "    ethernets:"
        echo "      eth0:"
        echo "        dhcp4: no"
        echo "        addresses:"
        echo "          - 192.168.1.100/24"
        echo "        routes:"
        echo "          - to: default"
        echo "            via: 192.168.1.1"
        echo "        nameservers:"
        echo "          addresses:"
        echo "            - 8.8.8.8"
        echo "            - 8.8.4.4"
        echo ""
        
        echo -e "${BLUE}Step 4: Save and apply changes${NC}"
        echo "  Ctrl+O, Enter, Ctrl+X (to save in nano)"
        echo "  sudo netplan apply"
        echo ""
        
        echo -e "${BLUE}Step 5: Verify${NC}"
        echo "  ip addr show"
        echo "  ping -c 3 8.8.8.8"
        
    else
        echo -e "${CYAN}CENTOS 9 - Using NetworkManager${NC}\n"
        
        echo -e "${BLUE}Step 1: Identify your connection name${NC}"
        echo "  nmcli con show"
        echo "  (Look for your connection, note the NAME)"
        echo ""
        
        echo -e "${BLUE}Step 2: Set IP to static and configure address${NC}"
        echo "  sudo nmcli con mod [connection-name] ipv4.method manual"
        echo "  sudo nmcli con mod [connection-name] ipv4.addresses 192.168.1.100/24"
        echo "  sudo nmcli con mod [connection-name] ipv4.gateway 192.168.1.1"
        echo "  sudo nmcli con mod [connection-name] ipv4.dns 8.8.8.8,8.8.4.4"
        echo ""
        
        echo -e "${YELLOW}Example - Full static configuration in one go:${NC}"
        echo "  sudo nmcli con mod MyConnection \\"
        echo "    ipv4.method manual \\"
        echo "    ipv4.addresses 192.168.1.100/24 \\"
        echo "    ipv4.gateway 192.168.1.1 \\"
        echo "    ipv4.dns \"8.8.8.8 8.8.4.4\""
        echo ""
        
        echo -e "${BLUE}Step 3: Activate the connection${NC}"
        echo "  sudo nmcli con down [connection-name]"
        echo "  sudo nmcli con up [connection-name]"
        echo ""
        
        echo -e "${BLUE}Step 4: Verify${NC}"
        echo "  nmcli device show"
        echo "  ip addr show"
        echo "  ping -c 3 8.8.8.8"
    fi
    
    echo ""
    echo -e "${YELLOW}Replace with YOUR values:${NC}"
    echo "  192.168.1.100 → Your desired static IP"
    echo "  192.168.1.1 → Your gateway (check: ip route show)"
    echo "  8.8.8.8, 8.8.4.4 → Your preferred DNS servers"
    echo ""
    
    read -p "Press Enter to return to main menu..."
    show_main_menu
}

################################################################################
# FUNCTION: DNS Troubleshooting
################################################################################
troubleshoot_dns() {
    show_header
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}TROUBLESHOOTING: DNS RESOLUTION ISSUES${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${GREEN}DNS Issue: 'ping google.com' fails but 'ping 8.8.8.8' works${NC}\n"
    
    echo -e "${BLUE}Step 1: Check current DNS servers${NC}"
    echo "  cat /etc/resolv.conf"
    echo "  OR"
    echo "  resolvectl status"
    echo ""
    echo -e "${YELLOW}Look for:${NC}"
    echo "  nameserver 8.8.8.8    (at least one must exist)"
    echo "  If none exist or all are 127.0.0.1, DNS is misconfigured"
    echo ""
    
    echo -e "${BLUE}Step 2: Test DNS lookup manually${NC}"
    echo "  nslookup google.com"
    echo "  dig google.com"
    echo ""
    echo -e "${YELLOW}If these fail:${NC}"
    echo "  Your DNS servers aren't accessible or don't work"
    echo ""
    
    echo -e "${BLUE}Step 3: Try a known working DNS server${NC}"
    echo "  nslookup google.com 8.8.8.8     (Google DNS)"
    echo "  nslookup google.com 1.1.1.1     (Cloudflare DNS)"
    echo ""
    echo -e "${YELLOW}If this works:${NC}"
    echo "  Your configured DNS server is the problem - change it"
    echo ""
    
    if [ "$SERVER_TYPE" = "ubuntu" ]; then
        echo -e "${CYAN}UBUNTU - Fix DNS${NC}\n"
        
        echo -e "${BLUE}Option 1: Edit Netplan (permanent)${NC}"
        echo "  sudo nano /etc/netplan/00-installer-config.yaml"
        echo "  Add or modify:"
        echo "    nameservers:"
        echo "      addresses:"
        echo "        - 8.8.8.8"
        echo "        - 8.8.4.4"
        echo "  sudo netplan apply"
        echo ""
        
        echo -e "${BLUE}Option 2: Edit /etc/resolv.conf directly (temporary)${NC}"
        echo "  sudo nano /etc/resolv.conf"
        echo "  Add:"
        echo "    nameserver 8.8.8.8"
        echo "    nameserver 8.8.4.4"
        echo "  Note: Changes are lost after reboot (use Netplan for permanent)"
        
    else
        echo -e "${CYAN}CENTOS 9 - Fix DNS${NC}\n"
        
        echo -e "${BLUE}Option 1: Set DNS via NetworkManager (permanent)${NC}"
        echo "  sudo nmcli con mod [connection-name] ipv4.dns \"8.8.8.8 8.8.4.4\""
        echo "  sudo nmcli con up [connection-name]"
        echo ""
        
        echo -e "${BLUE}Option 2: Edit /etc/resolv.conf (temporary)${NC}"
        echo "  sudo nano /etc/resolv.conf"
        echo "  Add:"
        echo "    nameserver 8.8.8.8"
        echo "    nameserver 8.8.4.4"
        echo "  Note: NetworkManager may overwrite this after restart"
    fi
    
    echo ""
    echo -e "${BLUE}Step 4: Verify DNS is working${NC}"
    echo "  nslookup google.com"
    echo "  ping -c 3 google.com"
    echo "  dig google.com (for detailed info)"
    echo ""
    
    echo -e "${YELLOW}Recommended DNS servers:${NC}"
    echo "  Google: 8.8.8.8, 8.8.4.4"
    echo "  Cloudflare: 1.1.1.1, 1.0.0.1"
    echo "  OpenDNS: 208.67.222.222, 208.67.220.220"
    echo ""
    
    read -p "Press Enter to return to main menu..."
    show_main_menu
}

################################################################################
# FUNCTION: Trace Network Path
################################################################################
trace_network_path() {
    show_header
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}TRACE NETWORK PATH TO DESTINATION${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${GREEN}What does tracepath/traceroute do?${NC}"
    echo "Shows the network path (hops) between your computer and a destination"
    echo "Useful for finding where connection problems occur\n"
    
    read -p "Enter destination (default: google.com): " destination
    destination=${destination:-"google.com"}
    
    echo ""
    echo -e "${BLUE}Running tracepath to: ${YELLOW}$destination${NC}\n"
    
    echo "Command: tracepath $destination"
    echo ""
    echo -e "${YELLOW}What to look for in output:${NC}"
    echo "  • Hop number increases with each router"
    echo "  • 'pmtu' shows maximum packet size"
    echo "  • Response times (ms) should be reasonable"
    echo "  • Look for '!' which indicates a problem at that hop"
    echo "  • '!' with 'no reply' = firewall or unreachable"
    echo ""
    
    # Try tracepath first (modern), fall back to traceroute
    if command -v tracepath &> /dev/null; then
        echo -e "${BLUE}Output:${NC}"
        tracepath "$destination"
    elif command -v traceroute &> /dev/null; then
        echo -e "${BLUE}Output:${NC}"
        traceroute "$destination"
    else
        echo -e "${RED}tracepath and traceroute not installed${NC}"
        echo ""
        echo "Install on Ubuntu:"
        echo "  sudo apt install iproute2  (for tracepath)"
        echo "  sudo apt install traceroute"
        echo ""
        echo "Install on CentOS 9:"
        echo "  sudo dnf install iproute   (for tracepath)"
        echo "  sudo dnf install traceroute"
    fi
    
    echo ""
    echo -e "${BLUE}Alternative: Using 'ping' for each hop${NC}"
    echo "  ping -c 3 [gateway-ip]     (first hop)"
    echo "  ping -c 3 8.8.8.8          (external DNS)"
    echo "  ping -c 3 $destination      (destination)"
    echo ""
    
    read -p "Press Enter to return to main menu..."
    show_main_menu
}

################################################################################
# FUNCTION: Check Services and Listening Ports
################################################################################
check_services() {
    show_header
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}CHECK LISTENING PORTS AND NETWORK SERVICES${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${CYAN}Check which ports are listening for incoming connections:${NC}\n"
    
    echo -e "${BLUE}Modern command (recommended):${NC}"
    echo "  sudo ss -tuln"
    echo ""
    echo -e "${YELLOW}Output explanation:${NC}"
    echo "  State: LISTEN = port is open and listening"
    echo "  Proto: tcp = TCP protocol, udp = UDP protocol"
    echo "  Local Address: [IP]:[PORT] = listening on this port"
    echo ""
    
    echo -e "${BLUE}Legacy command (if ss doesn't work):${NC}"
    echo "  sudo netstat -tuln"
    echo ""
    
    echo -e "${BLUE}Check active connections (not just listening):${NC}"
    echo "  sudo ss -tuan"
    echo ""
    
    echo -e "${CYAN}Check specific services:${NC}\n"
    
    if [ "$SERVER_TYPE" = "ubuntu" ]; then
        echo -e "${BLUE}On Ubuntu:${NC}"
        echo "  sudo systemctl status ssh"
        echo "  sudo systemctl status networking"
        echo "  systemctl list-units --type=service | grep network"
    else
        echo -e "${BLUE}On CentOS 9:${NC}"
        echo "  sudo systemctl status NetworkManager"
        echo "  sudo systemctl status sshd"
        echo "  systemctl list-units --type=service | grep network"
    fi
    
    echo ""
    echo -e "${CYAN}Common ports to look for:${NC}"
    echo "  Port 22: SSH (secure shell)"
    echo "  Port 80: HTTP (web server)"
    echo "  Port 443: HTTPS (secure web)"
    echo "  Port 3306: MySQL"
    echo "  Port 5432: PostgreSQL"
    echo "  Port 25/465/587: Email (SMTP)"
    echo "  Port 53: DNS"
    echo ""
    
    echo -e "${BLUE}View service status for common network services:${NC}"
    echo "  sudo systemctl status [service-name]"
    echo "  sudo systemctl start [service-name]"
    echo "  sudo systemctl stop [service-name]"
    echo "  sudo systemctl restart [service-name]"
    echo ""
    
    read -p "Press Enter to return to main menu..."
    show_main_menu
}

################################################################################
# FUNCTION: View All Network Configuration
################################################################################
view_network_config() {
    show_header
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}VIEW COMPLETE NETWORK CONFIGURATION${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${CYAN}Running comprehensive network information gathering...${NC}\n"
    
    echo -e "${GREEN}═ NETWORK INTERFACES ═${NC}"
    ip addr show
    
    echo ""
    echo -e "${GREEN}═ ROUTING TABLE ═${NC}"
    ip route show
    
    echo ""
    echo -e "${GREEN}═ DNS CONFIGURATION ═${NC}"
    resolvectl status 2>/dev/null || cat /etc/resolv.conf
    
    echo ""
    echo -e "${GREEN}═ LISTENING PORTS ═${NC}"
    sudo ss -tuln
    
    echo ""
    echo -e "${GREEN}═ SYSTEM HOSTNAME ═${NC}"
    hostnamectl status
    
    if [ "$SERVER_TYPE" = "centos" ]; then
        echo ""
        echo -e "${GREEN}═ NETWORKMANAGER CONNECTIONS ═${NC}"
        nmcli con show
        
        echo ""
        echo -e "${GREEN}═ NETWORKMANAGER DEVICES ═${NC}"
        nmcli device show
    else
        echo ""
        echo -e "${GREEN}═ NETPLAN CONFIGURATION ═${NC}"
        sudo cat /etc/netplan/*.yaml 2>/dev/null || echo "No netplan configs found"
    fi
    
    echo ""
    echo -e "${YELLOW}Note: Some commands may require sudo. Use 'sudo' prefix if permission denied.${NC}"
    
    echo ""
    read -p "Press Enter to return to main menu..."
    show_main_menu
}

################################################################################
# MAIN SCRIPT EXECUTION
################################################################################

# Start the script
select_server_type
show_main_menu
