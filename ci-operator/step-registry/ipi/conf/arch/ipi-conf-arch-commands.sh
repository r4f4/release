#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

CONFIG="${SHARED_DIR}/install-config.yaml"

declare -A SUBNETS
        SUBNETS["${CLUSTER_TYPE}-0-0"]="126"
        SUBNETS["${CLUSTER_TYPE}-0-1"]="1"
        SUBNETS["${CLUSTER_TYPE}-0-2"]="2"
        SUBNETS["${CLUSTER_TYPE}-0-3"]="3"
        SUBNETS["${CLUSTER_TYPE}-0-4"]="4"
        SUBNETS["${CLUSTER_TYPE}-1-0"]="126"
        SUBNETS["${CLUSTER_TYPE}-1-1"]="1"
        SUBNETS["${CLUSTER_TYPE}-1-2"]="2"
        SUBNETS["${CLUSTER_TYPE}-1-3"]="3"
        SUBNETS["${CLUSTER_TYPE}-1-4"]="4"

        # ensure LEASED_RESOURCE is set
        if [[ -z "${LEASED_RESOURCE}" ]]; then
          echo "Failed to acquire lease"
          exit 1
        fi

        # get cluster subnet or default it to 126
        cluster_subnet="${SUBNETS[${LEASED_RESOURCE}]}"
        if [[ -z "$cluster_subnet" ]]; then
           cluster_subnet=126
        fi

        # get cluster libvirt uri or default it the first host
        remote_libvirt_uri="qemu+tcp://${LIBVIRT_HOSTS[${LEASED_RESOURCE}]}/system"
        if [[ -z "$remote_libvirt_uri" ]]; then
           remote_libvirt_uri="qemu+tcp://${REMOTE_LIBVIRT_HOSTNAME}/system"
        fi
        echo $remote_libvirt_uri
        
        NETWORK_NAME="br$(printf ${LEASED_RESOURCE} | tail -c 3)"

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
    network: 
      if: ${NETWORK_NAME}
EOF

