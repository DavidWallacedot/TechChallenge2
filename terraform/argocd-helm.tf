resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  create_namespace = false

  depends_on = [
    module.eks,
    kubernetes_namespace_v1.argocd
  ]

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]
}