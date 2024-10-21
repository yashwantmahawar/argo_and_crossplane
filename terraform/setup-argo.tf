resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}


resource "kubernetes_cluster_role_binding" "argocd" {
  metadata {
    name = "argocd-server-rolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin" # Grant cluster-admin permissions
  }
  subject {
    kind      = "ServiceAccount"
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }
}

# Install Argo CD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace = kubernetes_namespace.argocd.metadata.0.name
  version   = "6.7.11" # Use the latest version

  # Customize values as needed
  values = [
    <<-EOF
    server:
      service:
        type: LoadBalancer # Expose Argo CD externally
    EOF
  ]
}

data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }
  depends_on = [helm_release.argocd]
}

resource "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret-1"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }
  data = {
    password = data.kubernetes_secret.argocd_initial_admin_secret.data.password
  }
}

resource "kubernetes_manifest" "argocd_application_set" {
  provider = kubernetes
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root-application-tf"
      namespace = kubernetes_namespace.argocd.metadata.0.name
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/yashwantmahawar/argo_and_crossplane"
        path           = "argocd/application-sets/root"
        targetRevision = "HEAD"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune : true
          selfHeal : true
        }
      }
    }
  }
}

# output "dummy" {
#   value = yamldecode(file("../argocd/application-sets/root/root-application-set.yaml"))
# }

