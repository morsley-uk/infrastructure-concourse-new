#!/usr/bin/env bash

#    _____           _        _ _    _____                                          
#   |_   _|         | |      | | |  / ____|                                         
#     | |  _ __  ___| |_ __ _| | | | |     ___  _ __   ___ ___  _   _ _ __ ___  ___ 
#     | | | '_ \/ __| __/ _` | | | | |    / _ \| '_ \ / __/ _ \| | | | '__/ __|/ _ \
#    _| |_| | | \__ \ || (_| | | | | |___| (_) | | | | (_| (_) | |_| | |  \__ \  __/
#   |_____|_| |_|___/\__\__,_|_|_|  \_____\___/|_| |_|\___\___/ \__,_|_|  |___/\___|
#                                                                                 
                                                                        
# Install Pivotal Concourse via Helm
 
echo '###############################################################################'
echo '# INSTALL CONCOURSE...'
echo '###############################################################################'
      
set -x    
                                        
export KUBECONFIG=$(pwd)/$FOLDER/kube_config.yaml

chmod 400 $(pwd)/$FOLDER/*.pem
  
# Concourse...

kubectl apply --filename $(pwd)/k8s/worker-storage-class.yaml
kubectl apply --filename $(pwd)/$FOLDER/worker-persistent-volume-0.yaml
kubectl apply --filename $(pwd)/$FOLDER/worker-persistent-volume-1.yaml

kubectl apply --filename $(pwd)/k8s/postgresql-storage-classs.yaml
kubectl apply --filename $(pwd)/$FOLDER/postgresql-persistent-volume-0.yaml

helm repo add concourse https://concourse-charts.storage.googleapis.com/

helm repo update

kubectl create namespace $NAMESPACE

helm install $NAME concourse/concourse --values $(pwd)/k8s/concourse-values.yaml --namespace $NAMESPACE

#kubectl --namespace $NAMESPACE rollout status $NAME

# https://whynopadlock.com
# https://www.ssllabs.com/ssltest/

# https://rancher.com/docs/rancher/v2.x/en/installation/options/troubleshooting/

set +x

echo '###############################################################################'
echo '# INSTALL CONCOURSE'
echo '###############################################################################'

exit 0