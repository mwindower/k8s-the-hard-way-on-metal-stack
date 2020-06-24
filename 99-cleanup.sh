#!/bin/bash

set -ex

PROJECT_ID=$(metalctl project ls | grep "${PROJECT_NAME}" | cut -f1)

for m in $(metalctl machine ls --project=${PROJECT_ID} -o template --template "{{ .id }}"); do \
    metalctl machine rm ${m}
done

metalctl network ip free ${KUBERNETES_PUBLIC_ADDRESS}