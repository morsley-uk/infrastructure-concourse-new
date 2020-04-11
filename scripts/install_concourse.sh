#!/usr/bin/env bash

#    _____           _        _ _    _____                                          
#   |_   _|         | |      | | |  / ____|                                         
#     | |  _ __  ___| |_ __ _| | | | |     ___  _ __   ___ ___  _   _ _ __ ___  ___ 
#     | | | '_ \/ __| __/ _` | | | | |    / _ \| '_ \ / __/ _ \| | | | '__/ __|/ _ \
#    _| |_| | | \__ \ || (_| | | | | |___| (_) | | | | (_| (_) | |_| | |  \__ \  __/
#   |_____|_| |_|___/\__\__,_|_|_|  \_____\___/|_| |_|\___\___/ \__,_|_|  |___/\___|
#                                                                                 
                                                                        
# Install Concourse via Helm

DIRECTORY="$(dirname "$0")"    
COMMON=${DIRECTORY}/../common-kubernetes/scripts  
 
bash ${COMMON}/header.sh "INSTALL CONCOURSE..."
      
bash ${COMMON}/print_divider.sh
      
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

if [[ -z "${DEPLOYMENT_NAME}" ]]; then   
    echo "No DEPLOYMENT_NAME supplied."
    exit 666
fi
echo "DEPLOYMENT_NAME: " ${DEPLOYMENT_NAME}

echo "pwd:" $(pwd)

bash ${COMMON}/print_divider.sh
                                        
export KUBECONFIG=${FOLDER}/kube_config.yaml

#chmod 400 ${FOLDER}/*.pem
#chmod 400 ${FOLDER}/*.pub
  
kubectl apply --filename $(pwd)/k8s/worker-storage-class.yaml
kubectl apply --filename ${FOLDER}/worker-persistent-volume-0.yaml
kubectl apply --filename ${FOLDER}/worker-persistent-volume-1.yaml

kubectl apply --filename $(pwd)/k8s/postgresql-storage-class.yaml
kubectl apply --filename ${FOLDER}/postgresql-persistent-volume-0.yaml

helm repo add concourse https://concourse-charts.storage.googleapis.com/

kubectl create namespace ${NAMESPACE}

kubectl label namespace ${NAMESPACE} istio-injection=enabled

helm install ${DEPLOYMENT_NAME} concourse/concourse \
  --values $(pwd)/k8s/concourse-values.yaml \
  --namespace ${NAMESPACE}

bash ${COMMON}/footer.sh "CONCOURSE INSTALLED"

exit 0