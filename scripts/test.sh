#!/bin/sh

echo "Hello from infrastructure-concourse-new/scripts"

echo "FOLDER: " ${FOLDER}
echo "NAMESPACE: " ${NAMESPACE}

echo "Trying to call script in common-kubernetes/scripts"

bash ../common-kubernetes/scripts/test.sh ${FOLDER} ${NAMESPACE}