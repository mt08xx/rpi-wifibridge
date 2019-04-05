#!/bin/bash

# Check if running in privileged mode
if [ ! -w "/sys" ] ; then
    echo "[Error] Not running in privileged mode."
    exit 1
fi

# Check environment variables
if [ ! "${DHCP_SERVER}" ] ; then
    echo "[Error] An interface must be specified."
    exit 1
fi

# Default values
true ${IP_ADDR_ETH:=$(/sbin/ip -4 -br addr show eth0| /bin/grep -Po "\\d+\\.\\d+\\.\\d+\\.\\d+")}
true ${SSID:=raspberry}
true ${CHANNEL:=11}
true ${WPA_PASSPHRASE:=passw0rd}
true ${HW_MODE:=g}

true ${INTERFACE_WLAN:=wlan0}
true ${INTERFACE_ETH:=eth0}


if [ ! -f "/etc/hostapd.conf" ] ; then
    cat > "/etc/hostapd.conf" <<EOF
interface=${INTERFACE_WLAN}
${DRIVER+"driver=${DRIVER}"}
ssid=${SSID}
hw_mode=${HW_MODE}
channel=${CHANNEL}
wpa=2
wpa_passphrase=${WPA_PASSPHRASE}
wpa_key_mgmt=WPA-PSK
# TKIP is no secure anymore
#wpa_pairwise=TKIP CCMP
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_ptk_rekey=600
wmm_enabled=1

# Activate channel selection for HT High Througput (802.11an)

${HT_ENABLED+"ieee80211n=1"}
${HT_CAPAB+"ht_capab=${HT_CAPAB}"}

# Activate channel selection for VHT Very High Througput (802.11ac)

${VHT_ENABLED+"ieee80211ac=1"}
${VHT_CAPAB+"vht_capab=${VHT_CAPAB}"}
EOF

fi

# 
echo "set ip_forward to 1"
echo "1" > /proc/sys/net/ipv4/ip_forward
cat /proc/sys/net/ipv4/ip_forward

# Setup interface and restart DHCP service
ip addr flush dev ${INTERFACE_WLAN}
ip addr add ${IP_ADDR_ETH}/32 dev ${INTERFACE_WLAN}
ip link set ${INTERFACE_WLAN} up

sudo /sbin/ip link set ${INTERFACE_WLAN} promisc on
sudo /sbin/ip link set ${INTERFACE_ETH} promisc on

/usr/sbin/parprouted ${INTERFACE_ETH} ${INTERFACE_WLAN} &
/usr/sbin/bcrelay -d -i ${INTERFACE_ETH} -o  ${INTERFACE_WLAN}
/usr/sbin/dhcp-helper -s ${DHCP_SERVER} -b ${INTERFACE_ETH}


# Capture external docker signals
trap 'true' SIGINT
trap 'true' SIGTERM
trap 'true' SIGHUP

echo "Starting HostAP daemon ..."
/usr/sbin/hostapd /etc/hostapd.conf &

wait $!

