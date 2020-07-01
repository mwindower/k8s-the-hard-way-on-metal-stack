#!/bin/bash

set -ex

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
CONTROLLER_EXTERNAL_IPS=("") # to be filled


cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

for i in {0..2}; do
    ip=${CONTROLLER_EXTERNAL_IPS[$i]}
    scp encryption-config.yaml metal@${ip}:~/
done