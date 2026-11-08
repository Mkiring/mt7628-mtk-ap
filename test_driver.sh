#!/bin/sh
# MT7628 WiFi AP Driver Test Script

echo "=== MT7628 WiFi AP Driver Test ==="
echo ""

# 1. Check if module is loaded
echo "1. Checking if module is loaded..."
if lsmod | grep -q mt7628; then
    echo "   ✓ Module mt7628 is loaded"
    lsmod | grep mt7628
else
    echo "   ✗ Module mt7628 is NOT loaded"
    echo "   Try: insmod mt7628.ko"
fi
echo ""

# 2. Check network interfaces
echo "2. Checking network interfaces..."
if ifconfig -a | grep -q wlan; then
    echo "   ✓ Wireless interfaces found:"
    ifconfig -a | grep wlan
else
    echo "   ✗ No wireless interfaces found"
fi
echo ""

# 3. Check wireless devices
echo "3. Checking wireless devices..."
if iw dev 2>/dev/null | grep -q Interface; then
    echo "   ✓ Wireless devices found:"
    iw dev
else
    echo "   ✗ No wireless devices found"
fi
echo ""

# 4. Check dmesg for driver messages
echo "4. Recent driver messages from dmesg:"
dmesg | grep -i "mt7628\|wifi\|wlan" | tail -20
echo ""

# 5. Check /sys/class/net
echo "5. Checking /sys/class/net..."
ls -l /sys/class/net/ | grep -E "wlan|ra"
echo ""

# 6. Check proc filesystem
echo "6. Checking /proc for driver info..."
if [ -d /proc/rt2880 ]; then
    echo "   ✓ /proc/rt2880 exists"
    ls -l /proc/rt2880/
else
    echo "   ✗ /proc/rt2880 not found"
fi
echo ""

echo "=== Test Complete ==="
