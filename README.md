# EzWoL - Easy Wake-on-LAN for OpenWRT

[![Build Status](https://github.com/yourusername/openwrt-ezwol/workflows/Build%20OpenWRT%20Package/badge.svg)](https://github.com/yourusername/openwrt-ezwol/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenWRT](https://img.shields.io/badge/OpenWRT-23.05-blue.svg)](https://openwrt.org/)

A simple and secure OpenWRT package that provides a network service for remotely waking up devices on your LAN using Wake-on-LAN (WoL) magic packets.

## 📥 Download

### Pre-built Packages

Download the latest pre-built IPK packages from [Releases](https://github.com/yourusername/openwrt-ezwol/releases):

- **x86_64**: For x86 soft routers and virtual machines
- **aarch64_cortex-a53**: For Raspberry Pi 3/4 and ARM64 devices
- **arm_cortex-a9**: For ARM routers
- **mipsel_24kc**: For Xiaomi routers and MT7621 devices
- **all**: Architecture-independent version (simple build)

### Build from Source

See [Quick Build](#quick-build-推荐) section below.


## Features

- 🌐 **Network Service**: Listens on a configurable TCP port (default: 61323) for WoL requests
- 🔐 **Authentication**: Shared secret key authentication to prevent unauthorized access
- 🎯 **Simple Protocol**: Send MAC address with authentication key to wake devices
- 🖥️ **LuCI Web Interface**: Easy configuration through OpenWRT's web interface
- 🔑 **Random Key Generator**: One-click generation of secure authentication keys
- 📊 **Service Status**: Real-time service status monitoring in web interface
- 🪶 **Lightweight**: Minimal resource usage, perfect for routers

## Requirements

- OpenWRT router (tested on 21.02+)
- `etherwake` package (for sending WoL packets)
- `socat` package (for network listening)
- LuCI web interface (for configuration)

## Quick Build (推荐)

### 使用自动打包脚本

**Linux / macOS / WSL:**
```bash
chmod +x build-ipk.sh
./build-ipk.sh
```

**Windows (使用 WSL):**
```cmd
build-ipk.bat
```

这将在 `build/` 目录生成 `ezwol_1.0.0-1_all.ipk` 文件。

### 快速部署到路由器

```bash
# 自动部署
chmod +x deploy-ipk.sh
./deploy-ipk.sh root@192.168.1.1

# 或手动复制安装
scp build/ezwol_*.ipk root@192.168.1.1:/tmp/
ssh root@192.168.1.1
opkg install /tmp/ezwol_*.ipk
```

### 开发测试（直接复制文件）

```bash
chmod +x deploy-dev.sh
./deploy-dev.sh root@192.168.1.1
```

详细构建说明请参考 [BUILD.md](BUILD.md)

> [!TIP]
> **GitHub Actions 故障排查**: 如果自动编译遇到问题，请查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## Installation

### Method 1: Using OpenWRT SDK (Recommended for Production)

1. Clone this repository to your OpenWRT build environment:
```bash
cd openwrt/package
git clone https://github.com/yourusername/openwrt-ezwol.git
```

2. Build the package:
```bash
cd openwrt
make package/openwrt-ezwol/compile
```

3. Install the generated IPK file on your router:
```bash
scp bin/packages/*/base/ezwol_*.ipk root@your-router-ip:/tmp/
ssh root@your-router-ip
opkg install /tmp/ezwol_*.ipk
```

### Method 2: Pre-built Package (Coming Soon)

Download the `.ipk` file and install:
```bash
opkg update
opkg install ezwol_*.ipk
```

## Configuration

### Via LuCI Web Interface (Recommended)

1. Log in to your OpenWRT router's web interface
2. Navigate to **Services → EzWoL**
3. Configure the following settings:
   - **Enable**: Check to enable the service
   - **Listen Port**: TCP port to listen on (default: 61323)
   - **Authentication Key**: Click "Generate" to create a random key, or enter your own
4. Click **Save & Apply**

### Via Command Line (UCI)

```bash
# Enable the service
uci set ezwol.config.enabled='1'

# Set the port (default: 61323)
uci set ezwol.config.port='61323'

# Set authentication key
uci set ezwol.config.auth_key='your-secret-key-here'

# Save and apply
uci commit ezwol
/etc/init.d/ezwol restart
```

### Via Configuration File

Edit `/etc/config/ezwol`:
```
config ezwol 'config'
    option enabled '1'
    option port '61323'
    option auth_key 'your-secret-key-here'
```

Then restart the service:
```bash
/etc/init.d/ezwol restart
```

## Usage

### Protocol Format

Send a request to the service using the following format:
```
AUTH_KEY:MAC_ADDRESS
```

Where:
- `AUTH_KEY` is your configured authentication key
- `MAC_ADDRESS` is the target device's MAC address (format: `AA:BB:CC:DD:EE:FF` or `AA-BB-CC-DD-EE-FF`)

### Examples

#### Using netcat (nc)

```bash
# Wake up a device with MAC address 00:11:22:33:44:55
echo "your-auth-key:00:11:22:33:44:55" | nc router-ip 61323
```

#### Using telnet

```bash
telnet router-ip 61323
# Then type: your-auth-key:00:11:22:33:44:55
# Press Enter
```

#### Using curl (via HTTP proxy or custom script)

```bash
# If you have a wrapper script that accepts HTTP requests
curl -X POST http://router-ip:8080/wol \
  -H "Authorization: Bearer your-auth-key" \
  -d "mac=00:11:22:33:44:55"
```

#### Python Script Example

```python
#!/usr/bin/env python3
import socket

def send_wol(router_ip, port, auth_key, mac_address):
    """Send WoL request to EzWoL service"""
    message = f"{auth_key}:{mac_address}\n"
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((router_ip, port))
        s.sendall(message.encode())
        response = s.recv(1024).decode()
        print(f"Response: {response}")

# Usage
send_wol("192.168.1.1", 61323, "your-auth-key", "00:11:22:33:44:55")
```

#### Shell Script Example

```bash
#!/bin/sh
# wol.sh - Wake-on-LAN helper script

ROUTER_IP="192.168.1.1"
ROUTER_PORT="61323"
AUTH_KEY="your-auth-key"

if [ -z "$1" ]; then
    echo "Usage: $0 <MAC_ADDRESS>"
    exit 1
fi

MAC_ADDRESS="$1"
echo "${AUTH_KEY}:${MAC_ADDRESS}" | nc ${ROUTER_IP} ${ROUTER_PORT}
```

## Service Management

### Start/Stop/Restart

```bash
# Start the service
/etc/init.d/ezwol start

# Stop the service
/etc/init.d/ezwol stop

# Restart the service
/etc/init.d/ezwol restart

# Check service status
/etc/init.d/ezwol status
```

### Enable/Disable Auto-start

```bash
# Enable auto-start on boot
/etc/init.d/ezwol enable

# Disable auto-start
/etc/init.d/ezwol disable
```

### View Logs

```bash
# View real-time logs
logread -f | grep ezwold

# View recent logs
logread | grep ezwold | tail -20
```

## Security Considerations

⚠️ **Important Security Notes:**

1. **Authentication Key**: Keep your authentication key secure. Anyone with this key can wake devices on your network.

2. **Network Exposure**: By default, the service listens on all interfaces. Consider using firewall rules to restrict access:
   ```bash
   # Only allow access from LAN
   iptables -A INPUT -p tcp --dport 61323 -i br-lan -j ACCEPT
   iptables -A INPUT -p tcp --dport 61323 -j DROP
   ```

3. **Port Selection**: If exposing to the internet (not recommended), use a non-standard port and strong authentication key.

4. **Rate Limiting**: Consider implementing rate limiting to prevent abuse:
   ```bash
   iptables -A INPUT -p tcp --dport 61323 -m limit --limit 10/min -j ACCEPT
   iptables -A INPUT -p tcp --dport 61323 -j DROP
   ```

## Troubleshooting

### Service won't start

1. Check if authentication key is set:
   ```bash
   uci get ezwol.config.auth_key
   ```

2. Check if required packages are installed:
   ```bash
   opkg list-installed | grep -E "etherwake|socat"
   ```

3. Check system logs:
   ```bash
   logread | grep ezwold
   ```

### WoL packets not working

1. Verify target device supports Wake-on-LAN and it's enabled in BIOS/UEFI
2. Check if target device is on the same network segment
3. Verify MAC address format is correct
4. Check router logs for successful packet transmission:
   ```bash
   logread | grep "WoL packet sent"
   ```

### Authentication failures

1. Verify the authentication key matches on both client and server
2. Check for extra spaces or newlines in the request
3. Ensure the format is exactly: `KEY:MAC` with no spaces

### Port already in use

1. Check if another service is using the port:
   ```bash
   netstat -tuln | grep 61323
   ```

2. Change the port in configuration:
   ```bash
   uci set ezwol.config.port='61324'
   uci commit ezwol
   /etc/init.d/ezwol restart
   ```

## Development

### File Structure

```
ezwol/
├── Makefile                          # OpenWRT package build file
├── files/
│   ├── ezwol.config                  # UCI configuration defaults
│   ├── ezwol.init                    # Init script
│   └── ezwold.sh                     # Main daemon script
└── luasrc/
    ├── controller/
    │   └── ezwol.lua                 # LuCI controller
    ├── model/
    │   └── cbi/
    │       └── ezwol.lua             # LuCI configuration view
    └── view/
        └── ezwol/
            └── status.htm            # Service status template
```

### Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on OpenWRT device
5. Submit a pull request

## License

MIT License - See LICENSE file for details

## Author

Created for OpenWRT community

## Changelog

### Version 1.0.0 (2024-11-24)
- Initial release
- Basic WoL functionality
- Authentication support
- LuCI web interface
- Random key generation
- Service status monitoring

## Support

For issues, questions, or contributions:
- GitHub Issues: https://github.com/yourusername/openwrt-ezwol/issues
- OpenWRT Forum: [Link to forum thread]

## Acknowledgments

- OpenWRT project for the excellent router firmware
- `etherwake` developers for the WoL implementation
- `socat` developers for the versatile network tool
