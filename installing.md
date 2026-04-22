# installing k8s
## setup node


    export HNAME="node2"
    export IP0="192.168.250.12/24"
    export IP1="192.168.251.12/24"
    uuidgen  | sed -e 's/-//g' |  sudo tee /etc/machine-id
    cat << EOF | sudo tee /etc/netplan/01_net.yaml
    network:
        version: 2
        ethernets:
            eth0:
              dhcp4: false
              addresses: [ ${IP0} ]
              routes:
              - to: 0.0.0.0/0
                via: 192.168.250.254
              nameservers:
                  addresses: [ 192.168.1.1]
            eth1:
              addresses: [ ${IP1}]
    EOF
    
    uuidgen  | sed -e 's/-//g' |  sudo tee /etc/machine-id
    sudo hostname ${HNAME}
    hostname | sudo tee /etc/hostname
    sudo netplan apply
    #sudo reboot

    mkdir -p ~/registry/certs
    mkdir -p ~/registry/data
    sudo vi /etc/ssl/openssl.cnf
    [ v3_ca ]
    subjectAltName=IP:192.168.250.100

    cd ~/registry
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout ./certs/registry.key -x509 -days 365 -out ./certs/registry.crt


    sudo mkdir -p /etc/containers/certs.d/192.168.250.100:5000/
    sudo cp ~/registry/certs/registry.crt /etc/containers/certs.d/192.168.250.100:5000/ca.crt


    podman run --name registry \
        -p 5000:5000 \
        -v ~/registry/data:/var/lib/registry \
        -v ~/registry/certs:/certs \
        -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt" \
        -e "REGISTRY_HTTP_TLS_KEY=/certs/registry.key" \
        --network podman \
        -d registry


    init kubeadm

    sudo kubeadm init --pod-network-cidr "10.32.0.0/12" --service-cidr "10.96.0.0/12" --control-plane-endpoint "192.168.250.101:6443" --upload-certs


    sudo kubeadm join 192.168.250.101:6443 --token kbtlut.qjne8hx1zfkl3nnx \
            --discovery-token-ca-cert-hash sha256:a1c024ef92b2ba68c4057cb1eb8221a644b60390b7ef75e057de4bae611e4b8c \
            --control-plane --certificate-key 7c090bfd0ea31785db682220b704b3b6b7e43303dff401659fa521ae2c9a4ec4

    kubeadm join 192.168.250.101:6443 --token kbtlut.qjne8hx1zfkl3nnx \
            --discovery-token-ca-cert-hash sha256:a1c024ef92b2ba68c4057cb1eb8221a644b60390b7ef75e057de4bae611e4b8c


    kubectl taint nodes --all node-role.kubernetes.io/control-plane-

  
    kubectl label nodes --all --overwrite node.kubernetes.io/exclude-from-external-load-balancers=false
    kubectl label nodes <node-name> --overwrite node.kubernetes.io/exclude-from-external-load-balancers=true
    
    kubectl label node node1 node.kubernetes.io/exclude-from-external-load-balancers-


    cat << EOF | tee metallb_config.yaml
    ---
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: pool1
      namespace: metallb-system
    spec:
      addresses:
      - 172.16.1.0/24
    ---
    apiVersion: metallb.io/v1beta1
    kind: BGPAdvertisement
    metadata:
      name: external
      namespace: metallb-system
    spec:
      ipAddressPools:
      - pool1
      aggregationLength: 32
    ---
    apiVersion: metallb.io/v1beta2
    kind: BGPPeer
    metadata:
      name: example
      namespace: metallb-system
    spec:
      myASN: 64512
      peerASN: 64512
      peerAddress: 172.16.11.1
    EOF



    router bgp 64512
      neighbor 192.168.250.10 remote-as 64512
      neighbor 192.168.250.11 remote-as 64512
      neighbor 192.168.250.12 remote-as 64512
    exit
