#!/bin/sh

DIRECTORY="$(dirname "$0")"

"${DIRECTORY}/../../common-kubernetes/scripts/are_deployments_ready.sh" "${FOLDER}" "${NAMESPACE}"