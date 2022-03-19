#!/bin/bash
MASTER_IP="10.10.0.10"

sudo kubeadm init --apiserver-advertise-address=$MASTER_IP

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

config_path="/home/vagrant/config"

if [ -d $config_path ]; then
    rm -f $config_path/*
else
    mkdir -p $config_path
fi

cp -i /etc/kubernetes/admin.conf $config_path/config
touch $config_path/join.sh
chmod +x $config_path/join.sh       


kubeadm token create --print-join-command > $config_path/join.sh


kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml