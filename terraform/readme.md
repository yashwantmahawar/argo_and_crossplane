Terraform
1. GKE
2. SA - gke-ops
3. kubernetes_cluster_role_binding
4. Helm install argo
5. helm install crossplane

Manual step
1. Create application for argocd
2. Create application for crossplane
    
    step 1 : argo_and_crossplnae/crossplane/bootstrap
    provider.yaml
    provider_config.yaml
    <!-- gke.yaml -->
    secrets.yaml
    sa - crosplane gke sa, WI (SA - gke-ops) - in yaml

    Step 2: argo_and_crossplnae/crossplane/tanentapp
    1. xp_gke.yaml
    2. gke_xrd.yaml
    
    Step 3:
    1. gke_claim.yaml
    2. add this new cluster in argo


Crossplane

tanent
