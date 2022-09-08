#/bin/bash

if ! [ $(id -u) = 0 ] ;
then
	echo "script must be run with root privileges:"
	echo "sudo $0"
	echo "exiting..."
	exit 1
fi

apt-get update -y
apt-get install -y ca-certificates \
    curl wget zip unzip \
    gnupg bash-completion \
    lsb-release apt-transport-https
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y containerd.io
rm /etc/containerd/config.toml
systemctl restart containerd
cd ~
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
rm cni-plugins-linux-amd64-v1.1.1.tgz
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
echo 'Acquire::https::packages.cloud.google.com::Verify-Peer "false";' | tee /etc/apt/apt.conf
apt-get update -y
apt-get install -y kubeadm kubectl kubelet
apt-mark hold  kubeadm kubectl kubelet
kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null

echo net.bridge.bridge-nf-call-ip6tables = 0 >> /etc/sysctl.conf
echo net.bridge.bridge-nf-call-iptables = 0 >> /etc/sysctl.conf
echo net.bridge.bridge-nf-call-arptables = 0 >> /etc/sysctl.conf
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf

echo REBOOTING!!!
sudo reboot
