#!/usr/bin/env bash
set -e
set -o pipefail

if [[ -z "${NAMESPACE}" ]]; then
    NAMESPACE=default
fi

if [[ -z "${POD_UID}" ]]; then
    PODID=$(crictl pods --namespace $NAMESPACE --name $POD_NAME -o json | jq -r --arg POD_NS "$NAMESPACE" --arg POD_NAME "$POD_NAME" '.items | map(select(.metadata.namespace==$POD_NS and .metadata.name==$POD_NAME)) | .[0].id')
else
    PODID=$(crictl pods --namespace $NAMESPACE --name $POD_NAME -o json | jq -r --arg POD_UID "$POD_UID" '.items | map(select(.metadata.uid==$POD_UID)) | .[0].id')
fi

if [[ -z "${CONTAINER}" ]]; then
    CTR_PID=$(crictl inspectp $PODID | jq .info.pid)
else
    CTR_PID=$(crictl ps --pod $PODID --name $CONTAINER -o json | jq -r --arg CONTAINER "$CONTAINER" '.containers | map(select(.metadata.name==$CONTAINER)) | .[0].id' | xargs crictl inspect | jq .info.pid)
fi

if [[ -z "${DRYRUN}" ]]; then
    nsenter --target $CTR_PID --net "$@"
else
    printf $(crictl inspectp $PODID | jq -r '.info.runtimeSpec.linux.namespaces[] |select(.type=="network") | .path')
fi
