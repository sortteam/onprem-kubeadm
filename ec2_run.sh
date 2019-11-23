#!/bin/bash
set -v
sudo apt install openvpn -y
sudo cp ~/ywj-client.ovpn /etc/openvpn/client.conf
sudo cp ~/ywj-client.ovpn /etc/openvpn/client/client.conf

sudo openvpn --client --config /etc/openvpn/client.conf --route-up fix_routes.sh &

sleep 5

# sudo /etc/init.d/openvpn start
# sudo systemctl start openvpn@client

echo "Adding default route to 10.8.0.1 with /0 mask..."
# sudo ip route add default via 10.8.0.1

echo "Removing /1 routes..."
sudo ip route del 0.0.0.0/1 via 10.8.0.1
sudo ip route del 128.0.0.0/1 via 10.8.0.1

exit 0
