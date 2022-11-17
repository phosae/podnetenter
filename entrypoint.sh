#!/usr/bin/env bash
set -e
set -o pipefail

PODID=$(crictl pods --namespace $NAMESPACE --name $POD_NAME -o json | jq -r --arg POD_UID "$POD_UID" '.items | map(select(.metadata.uid==$POD_UID)) | .[0].id')

if [[ -z "${CONTAINER}" ]]; then
    CTR_PID=$(crictl inspectp $PODID | jq .info.pid)
else
    CTR_PID=$(crictl ps --pod $PODID --name $CONTAINER -o json | jq -r --arg CONTAINER "$CONTAINER" '.containers | map(select(.metadata.name==$CONTAINER)) | .[0].id' | xargs crictl inspect | jq .info.pid)
fi

nsenter --target $CTR_PID --net $@