export HNAME="node2"
export IP="192.168.250.12/24"
export IP1="192.168.251.12/24"
uuidgen  | sed -e 's/-//g' |  sudo tee /etc/machine-id
cat << EOF | sudo tee /etc/netplan/01_net.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [ ${IP} ]
      routes:
      - to: 0.0.0.0/0
        via: 192.168.250.254
      nameservers:
        addresses: [ 192.168.1.1]
    eth1:
      dhcp4: false
      addresses: [ ${IP1} ]
EOF
uuidgen  | sed -e 's/-//g' |  sudo tee /etc/machine-id
sudo hostname ${HNAME}
hostname | sudo tee /etc/hostname
# sudo reboot
