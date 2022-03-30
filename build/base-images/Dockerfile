##### build kaniko #####
FROM golang:1.17.7-alpine3.14 as build

RUN apk add --update --no-cache git=~2 make=~4 bash=~5 && rm -f /var/cache/apk/*

ARG GOARCH=amd64
ARG KANIKO_RELEASE="1.7.0"

WORKDIR /go/src/github.com/GoogleContainerTools

RUN set -eux && \
    mkdir ./kaniko && \
    wget -nv -O /tmp/kaniko.tar.gz \
    https://github.com/GoogleContainerTools/kaniko/archive/refs/tags/v$KANIKO_RELEASE.tar.gz && \
    tar -xvf /tmp/kaniko.tar.gz -C ./kaniko --strip-components 1

WORKDIR /go/src/github.com/GoogleContainerTools/kaniko

RUN mkdir -p /kaniko/.docker && \
    make && make out/warmer

##### base image ######
FROM alpine:3.14 as base

RUN apk add --update --no-cache curl=~7 wget=~1 unzip=~6 ca-certificates=~20211220-r0 bash=~5 git=~2 gcc=~10 && rm -f /var/cache/apk/*


##### Tools #####
FROM base as tools

WORKDIR /tmp
ARG KUBERNETES_VERSION=v1.23.5    
RUN wget -nv https://dl.k8s.io/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl &&\
    mv kubectl /usr/bin/kubectl &&\
    chmod 765 /usr/bin/kubectl

ARG HELM_VERSION=v3.8.1
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget -nv  -O - https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xz &&\
    mv /tmp/linux-amd64/helm /usr/bin/helm &&\
    chmod 765 /usr/bin/helm

FROM base

RUN addgroup gitlab &&\
    adduser -S -G gitlab gitlab &&\
    adduser gitlab root &&\
    chown -R gitlab:root /home/gitlab &&\
    chmod g=u /home/gitlab/ &&\
    chmod g=u /etc/passwd


COPY --from=build /go/src/github.com/GoogleContainerTools/kaniko/out/executor /kaniko/executor
COPY --from=tools /usr/bin/kubectl /usr/bin/kubectl
COPY --from=tools /usr/bin/helm /usr/bin/helm
COPY --from=build /usr/local/go/bin/ /usr/local/go/bin/

RUN chown -R gitlab:root /kaniko &&\
    chown gitlab:root /usr/bin/kubectl

RUN helm plugin install https://github.com/chartmuseum/helm-push &&\
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
USER gitlab    
RUN mkdir -p /home/gitlab/.docker
ENV PATH $PATH:/usr/local/go/bin/:/usr/bin/helm:/usr/bin/kubectl:/kaniko
WORKDIR /home/gitlab




