#!/bin/bash
gitlab_tags="prod"
gitlab_url="https://gitlab.com/"
gitlab_token="GR1348941hGZkgiMbSFNerF1gPsP4"

#### minikube run #####
minikube start --driver=docker

kubectl version

#### Enable plagin minikube #####
minikube addons enable ingress
minikube addons enable metrics-server


#### creating  config faile for gitlab-runner ######
cat <<EOF > values.yaml
imagePullPolicy: IfNotPresent

## The GitLab Server URL (with protocol) that want to register the runner against
gitlabUrl: $gitlab_url

## The Registration Token for adding new Runners to the GitLab Server.
runnerRegistrationToken: "$gitlab_token"

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

  tags: "$gitlab_tags"



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

#### ServiceAccount gitlab-runner ######
kubectl create namespace gitlab-runner

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab
  namespace: gitlab-runner 
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab
  namespace: gitlab-runner
subjects:
  - kind: Group
    name: system:serviceaccounts
    namespace: gitlab-runner
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io

EOF
#### install gitlab-runner ######
helm repo add gitlab https://charts.gitlab.io
helm install --namespace gitlab-runner --create-namespace  gitlab-runner -f values.yaml gitlab/gitlab-runner


