#!/usr/bin/env bash

#    _____        _____                                            _____                _      ___  
#   |_   _|      / ____|                                          |  __ \              | |    |__ \ 
#     | |  ___  | |     ___  _ __   ___ ___  _   _ _ __ ___  ___  | |__) |___  __ _  __| |_   _  ) |
#     | | / __| | |    / _ \| '_ \ / __/ _ \| | | | '__/ __|/ _ \ |  _  // _ \/ _` |/ _` | | | |/ / 
#    _| |_\__ \ | |___| (_) | | | | (_| (_) | |_| | |  \__ \  __/ | | \ \  __/ (_| | (_| | |_| |_|  
#   |_____|___/  \_____\___/|_| |_|\___\___/ \__,_|_|  |___/\___| |_|  \_\___|\__,_|\__,_|\__, (_)  
#                                                                                          __/ |    
#                                                                                         |___/     

bash ../common-kubernetes/scripts/are_deployments_ready.sh ${FOLDER} ${NAMESPACE}

exit 0