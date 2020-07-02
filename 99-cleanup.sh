#!/bin/bash

if [[ ! -v KUBERNETES_PUBLIC_ADDRESS ]]; then
    echo "KUBERNETES_PUBLIC_ADDRESS is not set"
    exit 1
fi

if [[ ! -v PROJECT_NAME ]]; then
    echo "PROJECT_NAME is not set"
    exit 2
fi

if [[ ! -v PROJECT_ID ]]; then
    echo "PROJECT_ID is not set"
    exit 3
fi

set -ex

PROJECT_ID=$(metalctl project ls | grep "${PROJECT_NAME}" | cut -f1)

for m in $(metalctl machine ls --project=${PROJECT_ID} -o template --template "{{ .id }}"); do \
    metalctl machine rm ${m}
done

metalctl network ip free ${KUBERNETES_PUBLIC_ADDRESS}