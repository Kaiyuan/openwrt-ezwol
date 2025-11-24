#!/usr/bin/env python3
"""
EzWoL Test Client (Python)
A simple client to send Wake-on-LAN requests to EzWoL service
"""

import socket
import sys
import argparse


def send_wol_request(router_ip, port, auth_key, mac_address, timeout=5):
    """
    Send a WoL request to the EzWoL service
    
    Args:
        router_ip: IP address of the OpenWRT router
        port: Port number of EzWoL service
        auth_key: Authentication key
        mac_address: Target MAC address
        timeout: Socket timeout in seconds
    
    Returns:
        Response from server or None on error
    """
    message = f"{auth_key}:{mac_address}\n"
    
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(timeout)
            print(f"Connecting to {router_ip}:{port}...")
            s.connect((router_ip, port))
            
            print(f"Sending WoL request for MAC: {mac_address}")
            s.sendall(message.encode('utf-8'))
            
            response = s.recv(1024).decode('utf-8').strip()
            return response
    except socket.timeout:
        print("ERROR: Connection timeout")
        return None
    except socket.error as e:
        print(f"ERROR: Socket error: {e}")
        return None
    except Exception as e:
        print(f"ERROR: {e}")
        return None


def main():
    parser = argparse.ArgumentParser(
        description='Send Wake-on-LAN request to EzWoL service',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s 192.168.1.1 61323 mykey123 00:11:22:33:44:55
  %(prog)s -t 10 192.168.1.1 61323 mykey123 AA-BB-CC-DD-EE-FF
        '''
    )
    
    parser.add_argument('router_ip', help='Router IP address')
    parser.add_argument('port', type=int, help='EzWoL service port')
    parser.add_argument('auth_key', help='Authentication key')
    parser.add_argument('mac_address', help='Target MAC address (format: XX:XX:XX:XX:XX:XX or XX-XX-XX-XX-XX-XX)')
    parser.add_argument('-t', '--timeout', type=int, default=5, help='Connection timeout in seconds (default: 5)')
    
    args = parser.parse_args()
    
    # Validate MAC address format (basic check)
    mac = args.mac_address.replace('-', ':')
    if len(mac.split(':')) != 6:
        print("ERROR: Invalid MAC address format")
        print("Expected format: XX:XX:XX:XX:XX:XX or XX-XX-XX-XX-XX-XX")
        sys.exit(1)
    
    # Send request
    response = send_wol_request(
        args.router_ip,
        args.port,
        args.auth_key,
        mac,
        args.timeout
    )
    
    if response:
        print(f"\nResponse: {response}")
        if response.startswith("OK"):
            print("✓ WoL packet sent successfully!")
            sys.exit(0)
        else:
            print("✗ Request failed")
            sys.exit(1)
    else:
        print("✗ No response from server")
        sys.exit(1)


if __name__ == '__main__':
    main()
