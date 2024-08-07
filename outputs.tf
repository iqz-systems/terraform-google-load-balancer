output "forwarding_rule" {
  description = "Self link of the forwarding rule"
  value = google_compute_forwarding_rule.forwarding_rule.self_link
}

output "load_balancer_ip" {
    description = "IP Address of the load balancer"  
    value = google_compute_forwarding_rule.forwarding_rule.ip_address
}

output "load_balancer_domain_name" {
  description = "The domain name for the load balancer"
  value = google_compute_forwarding_rule.forwarding_rule.service_name
}