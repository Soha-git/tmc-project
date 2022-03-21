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

cat <<EOF > values.yaml 
## GitLab Runner Image
##
image: gitlab/gitlab-runner:alpine-v12.9.0

## Specify a imagePullPolicy
##
imagePullPolicy: IfNotPresent

## Default container image to use for initcontainer
init:
  image: busybox
  tag: latest

## The GitLab Server URL (with protocol) that want to register the runner against
##
gitlabUrl: https://gitlab.com/

## The Registration Token for adding new Runners to the GitLab Server. This must
## be retreived from your GitLab Instance.
##
runnerRegistrationToken: "GR13489419beyAnswu4Z2ZWe6YyCB"
## Unregister all runners before termination
##
unregisterRunners: true

## Configure the maximum number of concurrent jobs
##
concurrent: 10

## Defines in seconds how often to check GitLab for a new builds
##
checkInterval: 30

## For RBAC support:
##
rbac:
  create: true
  clusterWideAccess: false

## Configure integrated Prometheus metrics exporter
##
metrics:
  enabled: true

## Configuration for the Pods that that the runner launches for each new job
##
runners:
  ## Default container image to use for builds when none is specified
  ##
  image: ubuntu:16.04

  ## Specify the tags associated with the runner. Comma-separated list of tags.
  ##
  tags: "k8s-runner"

  ## Run all containers with the privileged flag enabled
  ## This will allow the docker:dind image to run if you need to run Docker
  ## commands. Please read the docs before turning this on:
  ##
  privileged: true

  ## Namespace to run Kubernetes jobs in (defaults to the same namespace of this release)
  ##
  namespace: gitlab

  cachePath: "/opt/cache"

  cache: {}
  builds: {}
  services: {}
  helpers: {}

resources: {}
EOF
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io
helm install --namespace gitlab  gitlab-runner -f values.yaml gitlab/gitlab-runner

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

