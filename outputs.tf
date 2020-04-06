#     ____        _               _       
#    / __ \      | |             | |      
#   | |  | |_   _| |_ _ __  _   _| |_ ___ 
#   | |  | | | | | __| '_ \| | | | __/ __|
#   | |__| | |_| | |_| |_) | |_| | |_\__ \
#    \____/ \__,_|\__| .__/ \__,_|\__|___/
#                    | |                  
#                    |_|                  

output "k8s_public_ip" {
  value = module.kubernetes-cluster.public_ip
}

output "k8s_public_dns" {
  value = module.kubernetes-cluster.public_dns
}

output "k8s_ssh_command" {
  value = module.kubernetes-cluster.ssh_command
}