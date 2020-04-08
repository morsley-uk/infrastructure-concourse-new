#!/usr/bin/env bash

#    _____        _____                                            _____                _      ___  
#   |_   _|      / ____|                                          |  __ \              | |    |__ \ 
#     | |  ___  | |     ___  _ __   ___ ___  _   _ _ __ ___  ___  | |__) |___  __ _  __| |_   _  ) |
#     | | / __| | |    / _ \| '_ \ / __/ _ \| | | | '__/ __|/ _ \ |  _  // _ \/ _` |/ _` | | | |/ / 
#    _| |_\__ \ | |___| (_) | | | | (_| (_) | |_| | |  \__ \  __/ | | \ \  __/ (_| | (_| | |_| |_|  
#   |_____|___/  \_____\___/|_| |_|\___\___/ \__,_|_|  |___/\___| |_|  \_\___|\__,_|\__,_|\__, (_)  
#                                                                                          __/ |    
#                                                                                         |___/     

echo '###############################################################################'
echo '# IS CONCOURSE READY...?'
echo '###############################################################################'
      
#set -x    
                                        
export KUBECONFIG=${FOLDER}/kube_config.yaml

CONCOURSE_NAMESPACE=concourse

# Requires:
# - kubectl
# - jq

print_deployment_headers () {
       
  print_deployment_footer
  printf "    Ready |  Expected | Available |   Updated | Deployment\n"
  print_deployment_footer
  
  return 0
  
}

print_deployment_row () {
       
  ready=$1
  expected=$2
  available=$3
  updated=$4
  deployment_name=$5
              
  printf "%9d | %9d | %9d | %9d | %s\n" ${ready} ${expected} ${available} ${updated} ${deployment_name}
  
  return 0
  
}

print_deployment_footer () {
         
  echo "----------+-----------+-----------+-----------+-------------------------"
  
  return 0
  
}

are_deployments_ready () {
  
  deployments_json=$(kubectl get deployments --namespace ${CONCOURSE_NAMESPACE} --output "json")
  number_of_deployments=$(jq '.items | length' <<< $deployments_json)
    
  print_deployment_headers
  
  is_ready="Yes"
  
  for ((i = 0 ; i < number_of_deployments ; i++)); do
        
    deployment_json=$(jq --arg i ${i} '.items[$i|tonumber]' <<< $deployments_json)
    
    deployment_name=$(jq  -r '.metadata.name' <<< $deployment_json)
    
    ready=$(jq '.status.readyReplicas' <<< $deployment_json)
    if is_numeric $ready; then
      ready=0
    fi
    
    expected=$(jq '.spec.replicas' <<< $deployment_json)
    
    available=$(jq '.status.availableReplicas' <<< $deployment_json)
    if is_numeric $available; then
      available=0
    fi
            
    updated=$(jq '.status.updatedReplicas' <<< $deployment_json)
    if is_numeric $updated; then
      updated=0
    fi

    print_deployment_row $ready $expected $available $updated $deployment_name
      
      if [ $ready -ne $expected ]; then
        is_ready="No"  
      fi
      
    done
    
    print_deployment_headers
    
  echo "${is_ready}"
  
  if [ "$is_ready" == "Yes" ]; then
    return 1
  fi 
  
  return 0
  
}

is_numeric () {
  
  if [ "$1" -eq "$1" ] 2>/dev/null; then
    return 1
  fi
  
  return 0
  
}

# Check all of the deployments in the Concourse namespace...

# i.e.
# NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
# -----------------------------------------------------------
# concourse-web          1/1     1            1           10h

echo "Are deployments ready...?"

while true; do
    
    #is_istio_ready
    are_deployments_ready

    if [[ $? == 1 ]]; then
        break
    fi

    sleep 5

done

print_divider
echo "Deployments:"
print_divider
kubectl get deployments --all-namespaces
print_divider

echo "Pods:"
print_divider
kubectl get pods --all-namespaces
print_divider

echo "Services:"
print_divider
kubectl get services --all-namespaces
print_divider

echo "Persistent Volumes:"
print_divider
kubectl get persisentvolumes --all-namespaces
print_divider

echo "Persistent Volume Claims:"
print_divider
kubectl get persisentvolumeclaims --all-namespaces
print_divider

#set +x

echo '###############################################################################'
echo '# CONCOURSE IS READY'
echo '###############################################################################'

exit 0