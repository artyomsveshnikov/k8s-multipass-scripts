#!/bin/bash

CONTROLPLANE_IP_ADDRESS=$(multipass list --format json | jq -r --arg node_name "controlplane" '.list[] | select(.name == $node_name) | .ipv4[0]')
echo CP_IP=$CONTROLPLANE_IP_ADDRESS
NODES_COUNT=$(multipass list --format json | jq -r 'select(.list[].name | startswith("node")) | length')
echo nodes count=$NODES_COUNT
for (( c=1; c<=$NODES_COUNT; c++ ))
do
	NODE_IP_ADDRESS=$(multipass list --format json | jq -r --arg node_name "node-$c" '.list[] | select(.name == $node_name) | .ipv4[0]')
	echo NODE_"$c"_IP=$NODE_IP_ADDRESS
	ssh -o StrictHostKeyChecking=no -i ./k8s-key k8sadmin@$NODE_IP_ADDRESS mkdir -p /home/k8sadmin/.kube
	#ssh -o StrictHostKeyChecking=no -i ./k8s-key k8sadmin@$CONTROLPLANE_IP_ADDRESS ls -lah /home/k8sadmin/.kube
	#ssh -o StrictHostKeyChecking=no -i ./k8s-key k8sadmin@$NODE_IP_ADDRESS ls -lah /home/k8sadmin/
	scp -o StrictHostKeyChecking=no -3 -i ./k8s-key k8sadmin@$CONTROLPLANE_IP_ADDRESS:/home/k8sadmin/.kube/config k8sadmin@$NODE_IP_ADDRESS:/home/k8sadmin/.kube/config
	#ssh -o StrictHostKeyChecking=no -i ./k8s-key k8sadmin@$NODE_IP_ADDRESS ls -lah /home/k8sadmin/.kube/
	NODE_JOIN_STRING=$(multipass exec controlplane -- sudo -u k8sadmin bash -c 'kubeadm token create --print-join-command')
	NODE_JOIN_STRING="$NODE_JOIN_STRING --ignore-preflight-errors=\"NumCPU,FileContent--proc-sys-net-bridge-bridge-nf-call-iptables,FileContent--proc-sys-net-ipv4-ip_forward\""
        echo command to join: $NODE_JOIN_STRING
	ssh -o SendEnv=NODE_JOIN_COMMAND -i ./k8s-key k8sadmin@$NODE_IP_ADDRESS sudo -u k8sadmin echo $NODE_JOIN_COMMAND | bash -
done
