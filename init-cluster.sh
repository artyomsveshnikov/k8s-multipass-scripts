#!/bin/bash

if ! [ $(id -u) = 0 ] ;
then
        echo "script must be run with root privileges:"
        echo "sudo $0"
        echo "exiting..."
        exit 1
fi

kubeadm init --ignore-preflight-errors="NumCPU,FileContent--proc-sys-net-bridge-bridge-nf-call-iptables,FileContent--proc-sys-net-ipv4-ip_forward" --pod-network-cidr "172.16.1.0/24" --service-cidr "10.24.34.0/24"
mkdir -p /home/k8sadmin/.kube 
cp -f /etc/kubernetes/admin.conf /home/k8sadmin/.kube/config
chown k8sadmin:k8sadmin /home/k8sadmin/.kube/config
