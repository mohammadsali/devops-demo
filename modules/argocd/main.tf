data "aws_secretsmanager_secret_version" "argocd_admin_password" {
  secret_id = "argocd-admin-password"
}
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.12"
  values = [
    <<-EOF
    server:
      service:
        type: LoadBalancer
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        loadBalancerSourceRanges:
          - 142.112.179.154/32
    configs:
      params:
        server.insecure: true
     EOF
  ]

  depends_on = [kubernetes_namespace.argocd]
}
