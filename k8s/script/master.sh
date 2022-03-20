#!/bin/bash
MASTER_IP="10.10.0.10"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"


sudo kubeadm init --apiserver-advertise-address=$MASTER_IP  --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_CIDR --node-name $NODENAME

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

config_path="/home/vagrant/config"

if [ -d $config_path ]; then
    rm -f $config_path/*
else
    mkdir -p $config_path
fi

sudo cp -i /etc/kubernetes/admin.conf $config_path/config
sudo chown -R vagrant:vagrant $config_path/config
touch $config_path/join.sh
chmod +x $config_path/join.sh       


kubeadm token create --print-join-command > $config_path/join.sh


kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml


curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get -y update
sudo apt-get -y install helm
helm version

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 
helm repo update 
helm install ingress-nginx ingress-nginx/ingress-nginx


kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

