#!/bin/bash

NODES_COUNT=${1:-1}
for (( c=1; c<=$NODES_COUNT; c++ ))
do
	multipass launch --name node-$c --cpus 1 --mem 2G --disk 100G --cloud-init cloudinit-k8s.yaml --timeout 100000
	multipass exec node-$c -- sudo ufw allow 22/tcp && sudo ufw allow 6443 && sudo systemctl restart sshd
	cat k8s-key.pub | multipass exec node-$c -- tee -a /home/ubuntu/.ssh/authorized_keys
	multipass exec node-$c -- sudo swapoff -a
done
