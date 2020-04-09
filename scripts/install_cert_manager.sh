#!/usr/bin/env bash

#    _____           _        _ _    _____          _          __  __                                   
#   |_   _|         | |      | | |  / ____|        | |        |  \/  |                                  
#     | |  _ __  ___| |_ __ _| | | | |     ___ _ __| |_ ______| \  / | __ _ _ __   __ _  __ _  ___ _ __ 
#     | | | '_ \/ __| __/ _` | | | | |    / _ \ '__| __|______| |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '__|
#    _| |_| | | \__ \ || (_| | | | | |___|  __/ |  | |_       | |  | | (_| | | | | (_| | (_| |  __/ |   
#   |_____|_| |_|___/\__\__,_|_|_|  \_____\___|_|   \__|      |_|  |_|\__,_|_| |_|\__,_|\__, |\___|_|   
#                                                                                        __/ |          
#                                                                                       |___/                                                        

echo '###############################################################################'
echo '# INSTALL CERT-MANAGER...'
echo '###############################################################################'

#set -x

export KUBECONFIG=${FOLDER}/kube_config.yaml

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml

kubectl create namespace cert-manager

helm repo add jetstack https://charts.jetstack.io

#helm repo update

helm install cert-manager jetstack/cert-manager \
  --version v0.14.2 \
  --namespace cert-manager \
  --wait

kubectl get all --namespace cert-manager

   
echo '###############################################################################'
echo '# CERT-MANAGER INSTALLED'
echo '###############################################################################'

#set +x

exit 0