##Overview

This document provides network troubleshooting tools for Linux system:

1. **Network Information Dump Script** - Captures all network configuration to both console and file
2. **Interactive Troubleshooting Guide** - Menu-driven troubleshooting specific to Ubuntu and CentOS 9
3. **Network Setup Documentation** - Detailed configuration guides for both servers

##Files Included

- `network_info_dump.sh` - Comprehensive network data gathering script
- `network_troubleshoot.sh` - Interactive troubleshooting menu
- `NETWORK_SETUP_UBUNTU.md` - Ubuntu 24.04 network documentation
- `NETWORK_SETUP_CENTOS9.md` - CentOS 9 network documentation
- `RESEARCH_NETWORK_DUMP_SCRIPT.md` - Research on script design decisions
- `INSTRUCTIONS.md` - Complete usage guide
- `README.md` - This file

##Quick Start

###On Ubuntu:
```bash
chmod +x network_info_dump.sh network_troubleshoot.sh
./network_info_dump.sh
./network_troubleshoot.sh
```

###On CentOS:
```bash
chmod +x network_info_dump.sh network_troubleshoot.sh
./network_info_dump.sh
./network_troubleshoot.sh
```

##Screenshots

###Ubuntu - Network Dump Script Output
![Ubuntu Network Dump](ubuntu_script_output.png)

###Ubuntu - Network Dump Output File
![Ubuntu Output File](ubuntu_output_file.png)

###Ubuntu - Troubleshooting Menu
![Ubuntu Troubleshooting](ubuntu_no_internet_connect.png)

###CentOS - Network Dump Script Output
![CentOS Network Dump](centos_script_output.png)

###CentOS - Network Dump Output File
![CentOS Output File](centos_output_file.png)

###CentOS - Troubleshooting Menu
![CentOS Troubleshooting](CentOS_static_ip_config.png)

##Features

###Network Info Dump Script
Captures 15 sections of network information:
- System information
- Network interfaces
- Routing tables
- DNS configuration
- NetworkManager/Netplan settings
- Listening ports
- ARP tables
- Firewall status
- And more...

**Output:** Timestamped file in `./network_dumps/` directory

###Troubleshooting Script
Interactive menu with troubleshooting examples:
1. No Internet Connectivity
2. Slow or Intermittent Connection
3. Configure Static IP Address
4. DNS Resolution Issues
5. Trace Network Path to Website
6. Check Listening Ports & Services
7. View All Network Configuration

**Server-Specific:** Different commands for Ubuntu vs CentOS 9

##Documentation

### Ubuntu Server (24.04 LTS)
- Hostname: WonSurface2
- IP Address: 172.25.225.22/20
- Gateway: 172.25.224.1
- DNS: 10.255.255.254
- See: NETWORK_SETUP_UBUNTU.md

###CentOS 9 Server
- Hostname: localhost.localdomain
- IP Address: 192.168.1.56/24
- Gateway: 192.168.1.1
- DNS: 192.168.1.1
- See: NETWORK_SETUP_CENTOS9.md

##Requirements

- Linux system (Ubuntu 24.04+ or CentOS 9)
- Bash shell
- Basic networking tools (ip, ss, ping, tracepath)
- net-tools package (optional)

##Installation
```bash
git clone https://github.com/won-portfolio/network-troubleshooting.git
cd network-troubleshooting
chmod +x *.sh
```

##Usage

### Run Network Dump
```bash
./network_info_dump.sh
```
Creates timestamped output file in `./network_dumps/`

Troubleshooting Guide
```bash
./network_troubleshoot.sh
```
Troubleshoot menu

#TCP/IP Model Integration

Scripts are organized around the TCP/IP model:
- **Layer 1 (Physical):** Interface status, cable checks
- **Layer 2 (Data Link):** ARP tables, MAC addresses
- **Layer 3 (Network):** IP addresses, routing, gateways
- **Layer 4 (Transport):** Listening ports, connections
- **Layer 5 (Application):** DNS, services, connectivity tests

#Research and Design

See `RESEARCH_NETWORK_DUMP_SCRIPT.md` details:
- what commands were used
- Modern vs legacy command 
- troubleshooting scenarios
- decisions or rationale


For more details on step-by-step instructions, see `INSTRUCTIONS.md`

```
