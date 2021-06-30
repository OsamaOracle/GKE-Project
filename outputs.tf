output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "service_IP" {
  description = "Service name"
  value       = kubernetes_service.loadbalancer.status.0.load_balancer.0.ingress.0.ip
}