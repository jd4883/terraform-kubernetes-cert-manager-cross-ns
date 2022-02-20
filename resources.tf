resource "kubernetes_secret" "certificate-replicas" {
  for_each = local.namespaces
  metadata {
    name      = module.cert-manager.certificates[var.domain].secret_name
    namespace = each.value
    annotations = {
      "replicator.v1.mittwald.de/replicate-from"  = join("/", [module.cert-manager.namespace, module.cert-manager.certificates[var.domain].secret_name])
      "replicator.v1.mittwald.de/replicated-keys" = "tls.crt,tls.key"
      "replicator.v1.mittwald.de/strip-labels"    = "true"
    }
  }
  data = {
    "tls.key" = ""
    "tls.crt" = ""
  }
  type = "kubernetes.io/tls"
  lifecycle {
    ignore_changes = [
      data,
      metadata.0.annotations["replicator.v1.mittwald.de/replicated-at"],
      metadata.0.annotations["replicator.v1.mittwald.de/replicated-from-version"],
    ]
  }
  depends_on = [module.cert-manager]
}
