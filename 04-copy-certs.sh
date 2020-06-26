#!/bin/bash

set -ex

WORKER_EXTERNAL_IPS=("212.34.83.23" "212.34.83.24" "212.34.83.25") # to be filled
CONTROLLER_EXTERNAL_IPS=("212.34.83.20" "212.34.83.21" "212.34.83.22") # to be filled

for i in {0..2}; do
    instance="worker-${i}"
    ip=${WORKER_EXTERNAL_IPS[$i]}
    scp ca.pem ${instance}-key.pem ${instance}.pem metal@${ip}:~/
done

for i in {0..2}; do
    instance="controller-${i}"
    ip=${CONTROLLER_EXTERNAL_IPS[$i]}
    scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
        service-account-key.pem service-account.pem metal@${ip}:~/
done