#!/bin/bash

if [ -f k8s-key ] ;
then 
	rm k8s-key*
fi

ssh-keygen -t rsa -N '' -f ./k8s-key
multipass launch --name controlplane --cpus 1 --mem 2G --disk 100G --cloud-init cloudinit-k8s.yaml --timeout 100000
multipass exec controlplane -- sudo ufw allow 22/tcp && sudo ufw allow 6443 && sudo systemctl restart sshd
cat k8s-key.pub | multipass exec controlplane -- tee -a /home/ubuntu/.ssh/authorized_keys
multipass exec controlplane -- sudo swapoff -a
cat init-cluster.sh | multipass exec controlplane -- sudo -u k8sadmin sudo bash -
