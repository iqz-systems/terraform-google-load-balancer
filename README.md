# terraform-google-load-balancer

Terraform module to create a Google Load Balancer.

This module uses the [google](https://registry.terraform.io/providers/hashicorp/google) provider.

## Usage

```hcl
module "load_balancer" {
  source            = "iqz-systems/load-balancer/google"
  version           = "1.1.0"

  project_id          = "my_project"
  region              = "us-east1"
  affinity_cookie_ttl_sec         = 0 # When the load balancing scheme is INTERNAL, this field is not used.
  connection_draining_timeout_sec = 10
  description                     = ""
  env                             = "dev"

  group_url           = "instance_group_id"
  backend_description = "Primary backend"
  additional_backends =  [{
    group          = "additional_instance_group_id"
    description    = ""
    balancing_mode = "CONNECTION" # Should always be CONNECTION for internal backend service
    failover       = true
  }]  # if no additional backends keep it []

  hc_port           = "443"
  http_health_check = false # Uses TCP health check
  tcp_health_check  = true
  unhealthy_threshold = 2
  healthy_threshold   = 2
  hc_timeout_sec      = 5

  ip_address         = ""
  reserve_ip_address = true
  address_type       = "EXTERNAL"

  service_directory_registrations = null
  service_label                   = null
  service_name                     = "my-app"

  timeout_sec = 30

  allow_global_access    = false
  is_mirroring_collector = false

  balancing_mode     = "CONNECTION" # Should always be CONNECTION for internal backend service
  check_interval_sec = 5
  enable_log_config  = true

  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"

  network      = "my-network"
  subnetwork   = "my-subnet"
  network_tier = "PREMIUM"

  port_specification = "USE_FIXED_PORT"
  ports              = [443]
  protocol           = "TCP"

  proxy_header     = "NONE"
  sample_rate      = "1.0"
  session_affinity = "CLIENT_IP"
}
```

## More than 5 ports

A forwarding rule accepts at most 5 ports. When `ports` holds more, the module splits it into groups of 5: the first group goes to the primary forwarding rule, and each later group gets an extra forwarding rule (`forwarding-rule-<env>-<service_name>-2`, `-3`, ...) on the same IP address and backend service. This is supported only for `load_balancing_scheme = "EXTERNAL"`; an internal load balancer with more than 5 ports fails at plan time.

Append new ports to the end of the list. Reordering moves ports between groups, which replaces the affected forwarding rules.

## All ports

Set `all_ports = true` to forward every port of `ip_protocol` to the backends through a single forwarding rule. The module then ignores `ports`, which may be empty, and creates no extra forwarding rules. This is supported for `load_balancing_scheme` `INTERNAL` or `EXTERNAL` with `ip_protocol` `TCP`, `UDP`, `SCTP` or `L3_DEFAULT`; any other combination fails at plan time.

A passthrough load balancer preserves the client source address, so the backends' firewall rules decide which ports are reachable. Every port the firewall admits on the backend VMs becomes reachable on the load balancer address.

Switching an existing load balancer from `ports` to `all_ports` replaces the primary forwarding rule: the rule is deleted and then created again on the same address. Rules on one address cannot overlap in ports. The module removes its own extra forwarding rules before it replaces the primary rule. Any forwarding rule on that address that this module did not create must be removed in an earlier apply.

## Labels

Set `labels` to a map of label keys and values to apply them to every forwarding rule and to the reserved IP address, for example to identify the application and environment in cost reports. The backend service and the health check do not support labels. Adding or changing labels updates the resources in place.

## Outputs

| Name | Description |
| --- | --- |
| `forwarding_rule` | Self link of the primary forwarding rule |
| `forwarding_rules` | Self links of all forwarding rules, the primary rule first |
| `load_balancer_ip` | IP address of the load balancer |
| `load_balancer_domain_name` | The domain name for the load balancer |
| `backend_service` | Self link of the regional backend service |

## Testing

```bash
terraform init -backend=false
terraform test
```

The tests use mocked providers and need no GCP credentials.
