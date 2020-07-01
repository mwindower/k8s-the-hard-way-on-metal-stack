#!/bin/bash

set -ex

WORKER_EXTERNAL_IPS=("") # to be filled
CONTROLLER_EXTERNAL_IPS=("") # to be filled

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