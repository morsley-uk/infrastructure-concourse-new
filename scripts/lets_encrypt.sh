#!/usr/bin/env bash

#    _          _   _       ______                             _   
#   | |        | | ( )     |  ____|                           | |  
#   | |     ___| |_|/ ___  | |__   _ __   ___ _ __ _   _ _ __ | |_ 
#   | |    / _ \ __| / __| |  __| | '_ \ / __| '__| | | | '_ \| __|
#   | |___|  __/ |_  \__ \ | |____| | | | (__| |  | |_| | |_) | |_ 
#   |______\___|\__| |___/ |______|_| |_|\___|_|   \__, | .__/ \__|
#                                                   __/ | |        
#                                                  |___/|_|        

# GENERATE SSL/TLS CERTIFICATES WITH LET'S ENCRYPT.

bash ../common-kubernetes/scripts/header.sh "SETTING UP LET'S ENCRYPT..."

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

echo "pwd: " $(pwd)

export KUBECONFIG=${FOLDER}/kube_config.yaml

# https://cert-manager.readthedocs.io/en/latest/reference/issuers.html

kubectl apply --filename $(pwd)/k8s/lets-encrypt-issuer.yaml --namespace ${NAMESPACE}

# To check if this has worked:
# kubectl get issuers --namespace ${NAMESPACE}
# kubectl describe issuer [ISSUER NAME] --namespace ${NAMESPACE}

# https://cert-manager.readthedocs.io/en/latest/reference/issuers.html

kubectl apply --filename $(pwd)/k8s/lets-encrypt-certificate.yaml --namespace ${NAMESPACE}

# To check if this has worked:
# kubectl get certificates --namespace ${NAMESPACE}
# kubectl describe certificate [CERTIFICATE NAME] --namespace ${NAMESPACE}

# Also, check the 'Ingress'. It should have another path added to it.
# kubectl get ingresses --namespace ${NAMESPACE}
# kubectl describe ingress [INGRESS NAME] --namespace ${NAMESPACE}

# https://whynopadlock.com
# https://www.ssllabs.com/ssltest/

bash ../common-kubernetes/scripts/footer.sh "LET'S ENCRYPT HAS BEEN SET UP"