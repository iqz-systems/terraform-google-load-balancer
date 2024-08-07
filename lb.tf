resource "google_compute_forwarding_rule" "forwarding_rule" {
  provider               = google-beta
  project                = var.project_id
  name                   = "forwarding-rule-${var.env}-${var.service_name}"
  description            = var.description
  allow_global_access    = var.allow_global_access
  network_tier           = var.network_tier
  network                = var.load_balancing_scheme == "INTERNAL"? var.network : null
  subnetwork             = var.load_balancing_scheme == "INTERNAL"? var.subnetwork : null
  load_balancing_scheme  = var.load_balancing_scheme
  backend_service        = google_compute_region_backend_service.lb_backend.self_link
  ports                  = var.ports
  region                 = var.region
  ip_address             = var.reserve_ip_address ? google_compute_address.lb_address[0].address : var.ip_address
  ip_protocol            = var.ip_protocol
  service_label          = var.service_label
  is_mirroring_collector = var.is_mirroring_collector
  dynamic service_directory_registrations {
    for_each = var.service_directory_registrations != null ? [var.service_directory_registrations] : []
    content {
        namespace = service_directory_registrations.value["namespace"]
        service   = service_directory_registrations.value["service"]
    }
  }
}

resource "google_compute_address" "lb_address" {
  count        = var.reserve_ip_address ? 1 : 0
  name         = "ip-address-${var.env}-${var.service_name}"
  subnetwork   = var.subnetwork_address
  address_type = var.address_type
  project      = var.project_id
  region       = var.region
}

resource "google_compute_region_backend_service" "lb_backend" {
  name                            = "backend-service-${var.env}-${var.service_name}"
  project                         = var.project_id
  description                     = var.description
  region                          = var.region
  protocol                        = var.protocol
  load_balancing_scheme           = var.load_balancing_scheme
  timeout_sec                     = var.timeout_sec
  health_checks                   = [google_compute_region_health_check.health_check.id]
  connection_draining_timeout_sec = var.connection_draining_timeout_sec
  session_affinity                = var.session_affinity
  affinity_cookie_ttl_sec         = var.affinity_cookie_ttl_sec

  log_config  {
    enable      = var.enable_log_config
    sample_rate = var.sample_rate
  }

  backend {
    group          = var.group_url
    description    = var.backend_description
    balancing_mode = var.balancing_mode
  }

  dynamic "backend" {
    for_each = var.additional_backends
    content {
        group = backend.value["group"]
        description = backend.value["description"]
        balancing_mode = backend.value["balancing-mode"]
    }
  }
}

resource "google_compute_region_health_check" "health_check" {
  name               = "hc-${var.env}-${var.service_name}"
  check_interval_sec = var.check_interval_sec
  timeout_sec        = var.hc_timeout_sec
  project            = var.project_id
  region             = var.region
  description        = var.description
  unhealthy_threshold = var.unhealthy_threshold
  healthy_threshold = var.healthy_threshold

  dynamic "http_health_check" {
    for_each = var.http_health_check ? ["http_hc"] : []
    content {
        host               = var.host
        request_path       = var.request
        response           = var.response
        port_name          = var.port_name
        port               = var.hc_port
        proxy_header       = var.proxy_header
        port_specification = var.port_specification
    }
  }

   dynamic "tcp_health_check" {
    for_each = var.tcp_health_check ? ["tcp_hc"] : []
    content {
        request            = var.request
        response           = var.response
        port               = var.hc_port
        proxy_header       = var.proxy_header
        port_specification = var.port_specification
    }
  }

  log_config {
    enable = var.enable_log_config
  }
}
