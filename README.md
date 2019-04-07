# rpi-wifibridge


## Environment
- Raspberry Pi 3B / 3B+
- Raspbian: `2018-11-13-raspbian-stretch-lite`
- Docker version 18.09.0, build 4d60db4

## Preparation
```
echo denyinterfaces wlan0 | sudo tee -a /etc/dhcpcd.conf
sudo sed -i -e 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
```

## build
```
docker build . -t mt08/rpi-wifibridge
```

## run
```
# At least DHCP_SERVER needs to be set.
DHCP_SERVER=$(grep -R "offered" /var/log/* 2>/dev/null | tail -n1 | awk '{print $(NF)}')
echo DHCP SERVER IP: ${DHCP_SERVER}

ex1) Default: SSID=raspberry WPA_PASSPHRASE=passw0rd CHANNEL=11
docker run -d --net host --privileged --rm --name rpi-wifibridge \
  -e DHCP_SERVER=${DHCP_SERVER} \
  mt08/rpi-wifibridge

ex2)
docker run -d --net host --privileged --rm --name rpi-wifibridge \
  -e SSID=sukina_ssid_name \
  -e CHANNEL=6 \
  -e WPA_PASSPHRASE=himitsu123 \
  -e DHCP_SERVER=${DHCP_SERVER} \
  mt08/rpi-wifibridge
```
