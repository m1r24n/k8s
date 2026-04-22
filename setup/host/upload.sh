 #!/usr/bin/env bash
# script to install k8s
# curl -L -O https://github.com/containerd/containerd/releases/download/v2.2.1/containerd-2.2.1-linux-amd64.tar.gz
# curl -L -O https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
# curl -L -O https://github.com/opencontainers/runc/releases/download/v1.4.0/runc.amd64
# curl -L -O https://github.com/containernetworking/plugins/releases/download/v1.9.0/cni-plugins-linux-amd64-v1.9.0.tgz
for i in node{0..2}
do
    scp containerd-2.2.1-linux-amd64.tar.gz ubuntu@${i}:~/
    scp containerd.service ubuntu@${i}:~/
    scp runc.amd64 ubuntu@${i}:~/
    scp cni-plugins-linux-amd64-v1.9.0.tgz ubuntu@${i}:~/
done
