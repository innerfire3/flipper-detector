#!/bin/bash
echo """----------------------------
|       By innerfire3      |
----------------------------
Starting Flipper Zero Detector...
The results will be showing below:
"""


# MAC address prefix to search for
prefix="80:E1:26"
logfile="flippers-found.txt"

# Resolve the Bluetooth Flipper name
resolve_bt_name() {
  local macaddr=$1
  bt_name=$(bluetoothctl info $macaddr | grep "Name" | awk -F ': ' '{print $2}')
  echo $bt_name
}

# Stop any ongoing discovery processes
stop_discovery() {
  bluetoothctl scan off > /dev/null 2>&1
  sleep 1  # Give it a moment to stop
}

# Log the output to the terminal and file
log_output() {
  local message=$1
  local datetime=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "[$datetime] $message" | tee -a $logfile
}

# Search for Flipper BT devices using bluetoothctl
bleflipper() {
  while :
  do
    stop_discovery

    # Start bluetoothctl scan and redirect output to /dev/null
    bluetoothctl scan on > /dev/null 2>&1 &
    scan_pid=$!

    sleep 15

    # Stop the scan process and redirect output to /dev/null
    stop_discovery
    kill $scan_pid 2>/dev/null

    # Get list of devices and filter by the prefix
    devices=$(bluetoothctl devices | grep -i "^Device $prefix")

    if [ -n "$devices" ]; then
      while IFS= read -r line; do
        macaddr=$(echo $line | awk '{print $2}')
        bt_name=$(resolve_bt_name $macaddr)
        log_output "Flipper Device found: MAC: $macaddr, Name: $bt_name"
      done <<< "$devices"
    else
      log_output "No Flippers Devices Found, Still Searching..."
    fi

    sleep 5
  done
}

bleflipper
