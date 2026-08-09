resource "kubernetes_manifest" "techchallenge2_argocd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "techchallenge2"
      namespace = "argocd"
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/DavidWallacedot/TechChallenge2.git"
        targetRevision = "gitops-argocd"
        path           = "k8s"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "techchallenge2"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }

        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argocd
  ]
}