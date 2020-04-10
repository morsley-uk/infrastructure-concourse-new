#!/usr/bin/env bash

#    _____                               
#   |_   _|                              
#     | |  _ __   __ _ _ __ ___  ___ ___ 
#     | | | '_ \ / _` | '__/ _ \/ __/ __|
#    _| |_| | | | (_| | | |  __/\__ \__ \
#   |_____|_| |_|\__, |_|  \___||___/___/
#                __/ |                  
#               |___/                   
                                                                               
#set -x    

bash ../common-kubernetes/scripts/header.sh "ADD INGRESS..."

echo "pwd: " $(pwd)
                                        
export KUBECONFIG=${FOLDER}/kube_config.yaml

kubectl apply --filename $(pwd)/k8s/concourse-ingress.yaml --namespace ${NAMESPACE}

#set +x

bash ../common-kubernetes/scripts/footer.sh "INGRESS ADDED"

exit 0