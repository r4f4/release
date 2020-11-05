#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

CONFIG="${SHARED_DIR}/install-config.yaml"

#expiration_date=$(date -d '4 hours' --iso=minutes --utc)


cat >> "${CONFIG}" << EOF
baseDomain: ${LEASED_RESOURCE}
metadata:
  name: ${CLUSTER_NAME}
controlPlane:
  architecture: ${ARCH}
  hyperthreading: Enabled
  name: master
  replicas: ${MASTER_REPLICAS}
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineCIDR: 192.168.${cluster_subnet}.0/24
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
compute:
- architecture: ${ARCH}
  hyperthreading: Enabled
  name: worker
  replicas: ${WORKER_REPLICAS}
platform:
  libvirt:
    URI: ${remote_libvirt_uri}
    network: ${NETWORK_NAME}
EOF

