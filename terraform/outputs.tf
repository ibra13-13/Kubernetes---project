output "gke_cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.gke_cluster.name
}

output "gke_cluster_endpoint" {
  description = "Endpoint for the GKE cluster"
  value       = google_container_cluster.gke_cluster.endpoint
}

output "gke_cluster_ca_cert" {
  description = "Cluster CA certificate"
  value       = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "web_helm_status" {
  description = "Status of the web Helm release"
  value       = helm_release.web.status
}

output "api_helm_status" {
  description = "Status of the api Helm release"
  value       = helm_release.api.status
}

output "mysql_helm_status" {
  description = "Status of the mysql Helm release"
  value       = helm_release.mysql.status
}
