#!/bin/bash

export PARTITION="nbg-w8101"
export MACHINE_SIZE="c1-xlarge-x86"
export PROJECT_NAME="k8s-the-hard-way"
export FIREWALL_IMAGE="firewall-ubuntu-2.0.20200617"
export WORKER_IMAGE="ubuntu-20.04.20200331"

# Create Test-Project
cloudctl project create \
    --name ${PROJECT_NAME} \
    --description "${PROJECT_NAME}"

export PROJECT_ID=$(metalctl project ls | grep "${PROJECT_NAME}" | cut -f1)

# Create Network
metalctl network allocate \
    --name ${PROJECT_NAME} \
    --partition ${PARTITION} \
    --project ${PROJECT_ID}

export NETWORK_ID=$(metalctl network list \
                        -o template --template "{{ .id }} {{ .name }}" \
                    | grep "${PROJECT_NAME}" \
                    | cut -d" " -f1)

# Create Firewall
metalctl firewall create \
    --project=${PROJECT_ID} \
    --partition=${PARTITION} \
    --image=${FIREWALL_IMAGE} \
    --size=${MACHINE_SIZE} \
    --networks=${NETWORK_ID},internet \
    --hostname=fw01

# Create Controllers
for i in {0..2}; do \
    metalctl machine create \
        --project=${PROJECT_ID} \
        --partition=${PARTITION} \
        --image=${WORKER_IMAGE} \
        --size=${MACHINE_SIZE} \
        --networks=${NETWORK_ID},internet \
        --hostname=controller-${i};
done

# Create Workers
for i in {0..2}; do \
    metalctl machine create \
        --project=${PROJECT_ID} \
        --partition=${PARTITION} \
        --image=${WORKER_IMAGE} \
        --size=${MACHINE_SIZE} \
        --networks=${NETWORK_ID},internet \
        --hostname=worker-${i};
done

# List external internet IPs of the machines
metalctl machine ls \
    --project=${PROJECT_ID} \
    -o template --template "{{ .allocation.hostname }} {{ index (index .allocation.networks 1).ips 0 }}" | grep controller
metalctl machine ls \
    --project=${PROJECT_ID} \
    -o template --template "{{ .allocation.hostname }} {{ index (index .allocation.networks 1).ips 0 }}" | grep worker

# List internal IPs of the machines
metalctl machine ls \
    --project=${PROJECT_ID} \
    -o template --template "{{ .allocation.hostname }} {{ index (index .allocation.networks 0).ips 0 }}" | grep controller
metalctl machine ls \
    --project=${PROJECT_ID} \
    -o template --template "{{ .allocation.hostname }} {{ index (index .allocation.networks 0).ips 0 }}" | grep worker

# Allocate public ip address for kube-apiserver
metalctl network ip allocate \
    --name kubeapiserver \
    --network internet \
    --project ${PROJECT_ID}

export KUBERNETES_PUBLIC_ADDRESS=$(
    metalctl network ip list \
        --project ${PROJECT_ID} \
        --network internet \
        -o template --template "{{ .ipaddress }} {{ .name }}" | grep kubeapiserver | cut -d" " -f1)