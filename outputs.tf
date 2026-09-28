output "forwarding_rule" {
  description = "Self link of the forwarding rule"
  value       = google_compute_forwarding_rule.forwarding_rule.self_link
}

output "load_balancer_ip" {
  description = "IP Address of the load balancer"
  value       = google_compute_forwarding_rule.forwarding_rule.ip_address
}

output "load_balancer_domain_name" {
  description = "The domain name for the load balancer"
  value       = google_compute_forwarding_rule.forwarding_rule.service_name
}

output "forwarding_rules" {
  description = "Self links of all forwarding rules, the primary rule first"
  value       = concat([google_compute_forwarding_rule.forwarding_rule.self_link], google_compute_forwarding_rule.forwarding_rule_extra[*].self_link)
}

output "backend_service" {
  description = "Self link of the regional backend service"
  value       = google_compute_region_backend_service.lb_backend.self_link
}
