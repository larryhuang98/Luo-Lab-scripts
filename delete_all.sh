#!/bin/bash

# List of GPU nodes
gpu_nodes=("gpu-0-0" "gpu-0-1" "gpu-0-2" "gpu-0-3" "gpu-0-4" "gpu-0-5" "gpu-0-6" "gpu-0-7" "gpu-0-8" "gpu-0-9" "gpu-1-0" "gpu-1-1" "gpu-1-2" "gpu-1-3" "gpu-1-4" "gpu-2-0" "gpu-2-1" "gpu-2-2" "gpu-2-3" "gpu-2-4")

# Loop through each GPU node
for node in "${gpu_nodes[@]}"; do
    echo "Deleting run_larry_* folders on $node"
    ssh $node "cd /state/partition1/ && rm -rf run_larry_*"
done

