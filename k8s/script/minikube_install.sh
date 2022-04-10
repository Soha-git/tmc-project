#!/bin/bash

#### install docker ####
if [ -f /etc/apt/sources.list.d/docker.list ]
then
sudo apt-get update -y  
sudo apt-get install -y docker.io
else
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update -y  
sudo apt-get install -y docker.io
fi

sudo usermod -aG docker $USER

#### install kubectl ####
sudo apt-get install -y apt-transport-https ca-certificates curl

if [ -e /usr/share/keyrings/kubernetes-archive-keyring.gpg ]
then
sudo apt-get update -y
sudo apt-get install -y  kubectl
else
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y  kubectl
fi

### install helm ####
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

##### install minikube ######
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube

sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/

newgrp docker
