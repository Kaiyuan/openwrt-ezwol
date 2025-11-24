#!/bin/sh
# EzWoL Test Client
# Usage: ./test-client.sh <router-ip> <port> <auth-key> <mac-address>

if [ $# -ne 4 ]; then
    echo "Usage: $0 <router-ip> <port> <auth-key> <mac-address>"
    echo "Example: $0 192.168.1.1 61323 mykey123 00:11:22:33:44:55"
    exit 1
fi

ROUTER_IP="$1"
PORT="$2"
AUTH_KEY="$3"
MAC_ADDRESS="$4"

echo "Sending WoL request to $ROUTER_IP:$PORT"
echo "Target MAC: $MAC_ADDRESS"
echo ""

# Send the request
RESPONSE=$(echo "${AUTH_KEY}:${MAC_ADDRESS}" | nc -w 2 "$ROUTER_IP" "$PORT")

if [ $? -eq 0 ]; then
    echo "Response: $RESPONSE"
    echo "Request sent successfully!"
else
    echo "ERROR: Failed to connect to server"
    exit 1
fi
