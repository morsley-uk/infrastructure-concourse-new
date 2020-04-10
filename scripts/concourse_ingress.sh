#!/usr/bin/env bash

#    _____                               
#   |_   _|                              
#     | |  _ __   __ _ _ __ ___  ___ ___ 
#     | | | '_ \ / _` | '__/ _ \/ __/ __|
#    _| |_| | | | (_| | | |  __/\__ \__ \
#   |_____|_| |_|\__, |_|  \___||___/___/
#                __/ |                  
#               |___/                   
                                                                               
bash ../common-kubernetes/scripts/header.sh "ADD INGRESS..."

if [[ -z "${FOLDER}" ]]; then   
    echo "No FOLDER supplied."
    exit 666
fi
echo "FOLDER:" ${FOLDER}

if [[ -z "${NAMESPACE}" ]]; then   
    echo "No NAMESPACE supplied."
    exit 666
fi
echo "NAMESPACE:" ${NAMESPACE}

echo "pwd:" $(pwd)
                                        
export KUBECONFIG=${FOLDER}/kube_config.yaml

kubectl apply --filename $(pwd)/k8s/concourse-ingress.yaml --namespace ${NAMESPACE}

bash ../common-kubernetes/scripts/footer.sh "INGRESS ADDED"

exit 0