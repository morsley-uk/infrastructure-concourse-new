#!/usr/bin/env bash

#    _____       _          _   _       ______                             _     _____                _         ___  
#   |_   _|     | |        | | ( )     |  ____|                           | |   |  __ \              | |       |__ \ 
#     | |  ___  | |     ___| |_|/ ___  | |__   _ __   ___ _ __ _   _ _ __ | |_  | |__) |___  __ _  __| |_   _     ) |
#     | | / __| | |    / _ \ __| / __| |  __| | '_ \ / __| '__| | | | '_ \| __| |  _  // _ \/ _` |/ _` | | | |   / / 
#    _| |_\__ \ | |___|  __/ |_  \__ \ | |____| | | | (__| |  | |_| | |_) | |_  | | \ \  __/ (_| | (_| | |_| |  |_|  
#   |_____|___/ |______\___|\__| |___/ |______|_| |_|\___|_|   \__, | .__/ \__| |_|  \_\___|\__,_|\__,_|\__, |  (_)  
#                                                               __/ | |                                  __/ |       
#                                                              |___/|_|                                 |___/        

bash ../common-kubernetes/scripts/header.sh "IS LET'S ENCRYPT...?"

if [[ -z "${FOLDER}" ]]; then   
    echo "No FOLDER supplied."
    exit 666
fi
echo "FOLDER:" ${FOLDER}

export KUBECONFIG=${FOLDER}/kube_config.yaml

echo "pwd:" $(pwd)

kubectl get all --all-namespaces

#
#
# kubectl apply --filename lets-encrypt-issuer.yaml --namespace ${NAMESPACE}
#

# To check if this has worked:
# kubectl get issuers --namespace ${NAMESPACE}
# kubectl describe issuer [ISSUER NAME] --namespace ${NAMESPACE}

#
# kubectl apply --filename lets-encrypt-certificate.yaml --namespace ${NAMESPACE}
#

# To check if this has worked:
# kubectl get certificates --namespace ${NAMESPACE}
# kubectl describe certificate [CERTIFICATE NAME] --namespace ${NAMESPACE}

# Also, check the 'Ingress'. It should have another path added to it.
# kubectl get ingresses --namespace ${NAMESPACE}
# kubectl describe ingress [INGRESS NAME] --namespace ${NAMESPACE}

# https://whynopadlock.com
# https://www.ssllabs.com/ssltest/

bash ../common-kubernetes/scripts/footer.sh "LET'S ENCRYPT IS READY"