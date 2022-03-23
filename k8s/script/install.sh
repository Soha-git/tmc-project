#!/bin/bash

sudo apt-get remove docker docker.io containerd runc
sudo apt-get update
sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg  

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y  
sudo apt-get install -y containerd.io

sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube

sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/

minikube start

kubectl version

minikube addons enable ingress

cat <<EOF > values.yaml
imagePullPolicy: IfNotPresent

## The GitLab Server URL (with protocol) that want to register the runner against
gitlabUrl: https://gitlab.com/

## The Registration Token for adding new Runners to the GitLab Server.
runnerRegistrationToken: "GR1348941hGZkgiMbSFNerF1gPsP4"

## Unregister all runners before termination
unregisterRunners: true

## Configure the maximum number of concurrent jobs
concurrent: 10

## Defines in seconds how often to check GitLab for a new builds
checkInterval: 30
terminationGracePeriodSeconds: 3600
sessionServer:
  enabled: false

## For RBAC support:
rbac:
  create: false

  rules: []

  clusterWideAccess: false

  serviceAccountName: gitlab

  podSecurityPolicy:
    enabled: false
    resourceNames:
    - gitlab-runner
metrics:
  enabled: false


  portName: metrics

  port: 9252


  serviceMonitor:
    enabled: false

service:
  enabled: false

  type: ClusterIP

runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "{{.Release.Namespace}}"
        image = "ubuntu:16.04"

  tags: "k8s,dev"



  cache: {}
  ## DEPRECATED: See https://docs.gitlab.com/runner/install/kubernetes.html#additional-configuration
  builds: {}

  services: {}

  helpers: {}
##
securityContext:
  runAsUser: 100
  # runAsGroup: 65533
  fsGroup: 65533

resources: {}

affinity: {}

nodeSelector: {}

tolerations: []

hostAliases: []

podAnnotations: {}

podLabels: {}
secrets: []

configMaps: {}

EOF

