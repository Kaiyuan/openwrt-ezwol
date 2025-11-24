#!/bin/sh
# EzWoL Daemon - Wake-on-LAN service
# Listens for authenticated requests and sends WoL magic packets

PORT="${1:-61323}"
AUTH_KEY="${2}"

# Logging function
log_msg() {
	logger -t ezwold "$1"
}

# Validate parameters
if [ -z "$AUTH_KEY" ]; then
	log_msg "ERROR: Authentication key not provided"
	exit 1
fi

# Check for required commands
if ! command -v socat >/dev/null 2>&1; then
	log_msg "ERROR: socat not found. Please install socat package."
	exit 1
fi

if ! command -v etherwake >/dev/null 2>&1 && ! command -v ether-wake >/dev/null 2>&1; then
	log_msg "ERROR: etherwake/ether-wake not found. Please install etherwake package."
	exit 1
fi

# Determine which WoL command to use
if command -v etherwake >/dev/null 2>&1; then
	WOL_CMD="etherwake"
else
	WOL_CMD="ether-wake"
fi

log_msg "Starting EzWoL daemon on port $PORT with $WOL_CMD"

# Create inline handler script
HANDLER_SCRIPT='
read -r request
key="${request%%:*}"
mac="${request#*:}"

if [ "$key" != "'"$AUTH_KEY"'" ]; then
	logger -t ezwold "Authentication failed"
	echo "ERROR: Authentication failed"
	exit 1
fi

if ! echo "$mac" | grep -qE "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"; then
	logger -t ezwold "Invalid MAC address: $mac"
	echo "ERROR: Invalid MAC address"
	exit 1
fi

logger -t ezwold "Sending WoL packet to $mac"
'"$WOL_CMD"' "$mac" 2>&1 | logger -t ezwold

if [ $? -eq 0 ]; then
	logger -t ezwold "WoL packet sent successfully to $mac"
	echo "OK: WoL packet sent to $mac"
else
	logger -t ezwold "Failed to send WoL packet to $mac"
	echo "ERROR: Failed to send WoL packet"
	exit 1
fi
'

# Start socat listener
exec socat TCP-LISTEN:$PORT,reuseaddr,fork SYSTEM:"$HANDLER_SCRIPT"

