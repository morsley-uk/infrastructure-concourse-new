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

export KUBECONFIG=${FOLDER}/kube_config.yaml

kubectl apply --filename lets-encrypt-issuer.yaml --namespace ${NAMESPACE}

# To check if this has worked:
# kubectl get issuers --namespace ${NAMESPACE}
# kubectl describe issuer [ISSUER NAME] --namespace ${NAMESPACE}

kubectl apply --filename lets-encrypt-certificate.yaml --namespace ${NAMESPACE}

# To check if this has worked:
# kubectl get certificates --namespace ${NAMESPACE}
# kubectl describe certificate [CERTIFICATE NAME] --namespace ${NAMESPACE}

# Also, check the 'Ingress'. It should have another path added to it.
# kubectl get ingresses --namespace ${NAMESPACE}
# kubectl describe ingress [INGRESS NAME] --namespace ${NAMESPACE}

# https://whynopadlock.com
# https://www.ssllabs.com/ssltest/

bash ../common-kubernetes/scripts/footer.sh "LET'S ENCRYPT HAS BEEN SET UP"