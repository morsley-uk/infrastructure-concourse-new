#!/usr/bin/env bash

#    _____           _        _ _   _____     _   _       
#   |_   _|         | |      | | | |_   _|   | | (_)      
#     | |  _ __  ___| |_ __ _| | |   | |  ___| |_ _  ___  
#     | | | '_ \/ __| __/ _` | | |   | | / __| __| |/ _ \ 
#    _| |_| | | \__ \ || (_| | | |  _| |_\__ \ |_| | (_) |
#   |_____|_| |_|___/\__\__,_|_|_| |_____|___/\__|_|\___/ 
#                                                       
                                                       
# Install Istio 1.5

echo '###############################################################################'
echo '# INSTALL ISTIO...'
echo '###############################################################################'

export KUBECONFIG=${FOLDER}/kube_config.yaml

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.5.1 sh -

cd istio-1.5.1

export PATH=$PWD/bin:$PATH

istioctl manifest apply \
   --set addonComponents.grafana.enabled=true \
   --set addonComponents.kiali.enabled=true \
   --set addonComponents.prometheus.enabled=true \
   --set addonComponents.tracing.enabled=true
   
echo '###############################################################################'
echo '# ISTIO INSTALLED'
echo '###############################################################################'

exit 0