#!/bin/bash

# ... (gcloud authentication) ...
#update username and password
argocd  login xx.xx.xx.xx --insecure --username admin --password xxxxxxx
# Get cluster information (name, location, project) for clusters with the specified label
cluster_info=$(gcloud container clusters list \
  --format="json(name,location)" )
  #--filter="resourceLabels.target-argocd-cluster=true"

# Loop through the cluster information and add them to Argo CD
for cluster in $(echo "${cluster_info}" | jq -r '.[] | @base64'); do
  _jq() {
    echo ${cluster} | base64 -d | jq -r ${1}
  }

  cluster_name=$(_jq '.name')
  cluster_location=$(_jq '.location')

  echo "Adding cluster: ${cluster_name} in ${cluster_location}"

  

  gcloud container clusters get-credentials "${cluster_name}" --region="${cluster_location}"

  context_path=$(kubectl config current-context)
  echo context_path: ${context_path}
  
  echo argocd cluster add "${context_path}" \
    --kubeconfig ~/.kube/config \
    --namespace argocd \
    --name "${cluster_name}" --upsert --yes

  argocd cluster add "${context_path}" \
    --kubeconfig ~/.kube/config \
    --name "${cluster_name}" --upsert --yes
done