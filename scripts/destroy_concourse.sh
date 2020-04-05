#!/usr/bin/env bash
                                
# Destroy Pivotal Concourse via Helm

echo '###############################################################################'
echo '# DESTROYING CONCOURSE...'
echo '###############################################################################'

set -x    

# Remove the 'concourse' folder...
echo rm -rf $(pwd)/$FOLDER/
                                        
#export KUBECONFIG=$(pwd)/$FOLDER/kube_config.yaml

#chmod 400 $(pwd)/$FOLDER/*.pem

# Concourse...

# Detach persistent volumes...

# Detach persistent volumes...

#kubectl apply --filename $(pwd)/k8s/worker-storage-class.yaml
#kubectl apply --filename $(pwd)/$FOLDER/worker-persistent-volume.yaml

#kubectl apply --filename $(pwd)/k8s/postgresql-storage-classsc.yaml
#kubectl apply --filename $(pwd)/$FOLDER/postgresql-persistent-volume.yaml

#helm repo add concourse https://concourse-charts.storage.googleapis.com/

#helm repo update

#kubectl create namespace $NAMESPACE

#helm install $NAME concourse/concourse --values $(pwd)/k8s/concourse-values.yaml --namespace $NAMESPACE

#kubectl --namespace $NAMESPACE rollout status $NAME

# https://whynopadlock.com
# https://www.ssllabs.com/ssltest/

# https://rancher.com/docs/rancher/v2.x/en/installation/options/troubleshooting/

set +x

echo '###############################################################################'
echo '# CONCOURSE DESTROYED'
echo '###############################################################################'

exit 0