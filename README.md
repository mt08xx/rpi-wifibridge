# rpi-wifibridge


## build
docker build . mt08/rpi-wifibridge


## run
docker run -it --net host --privileged --rm --name rpi-wifibridge \
  -e INTERFACE=wlan0 \
  -e INTERFACE2=eth0 \
  -e AP_ADDR=<same as eth IP> \
  -e DHCP_SERVER=<DHCP's IP address> \
  -e SSID=<SSID> \
  -e WPA_PASSPHRASE=<password>
  mt08/rpi-wifibridge
