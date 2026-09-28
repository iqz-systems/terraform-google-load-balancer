mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id            = "test-project"
  region                = "us-east1"
  env                   = "dev"
  service_name          = "app"
  group_url             = "projects/test-project/zones/us-east1-b/instanceGroups/app-ig"
  hc_port               = "443"
  load_balancing_scheme = "EXTERNAL"
  reserve_ip_address    = true
  address_type          = "EXTERNAL"
}

run "five_ports_use_a_single_rule" {
  command = apply

  variables {
    ports = ["1", "2", "3", "4", "5"]
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule.ports == toset(["1", "2", "3", "4", "5"])
    error_message = "The primary rule should carry all five ports."
  }

  assert {
    condition     = length(google_compute_forwarding_rule.forwarding_rule_extra) == 0
    error_message = "No extra rules should be created for five ports."
  }

  assert {
    condition     = output.forwarding_rules == [google_compute_forwarding_rule.forwarding_rule.self_link]
    error_message = "forwarding_rules should list only the primary rule."
  }
}

run "six_ports_add_one_extra_rule_on_the_same_ip_and_backend" {
  command = apply

  variables {
    ports = ["1", "2", "3", "4", "5", "6"]
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule.ports == toset(["1", "2", "3", "4", "5"])
    error_message = "The primary rule should carry the first five ports."
  }

  assert {
    condition     = length(google_compute_forwarding_rule.forwarding_rule_extra) == 1
    error_message = "Six ports should create exactly one extra rule."
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule_extra[0].ports == toset(["6"])
    error_message = "The extra rule should carry only the sixth port."
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule_extra[0].name == "forwarding-rule-dev-app-2"
    error_message = "The extra rule should be named with a -2 suffix."
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule_extra[0].ip_address == google_compute_forwarding_rule.forwarding_rule.ip_address
    error_message = "The extra rule should share the primary rule's IP address."
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule_extra[0].backend_service == google_compute_region_backend_service.lb_backend.self_link
    error_message = "The extra rule should point at the module's backend service."
  }

  assert {
    condition     = output.backend_service == google_compute_region_backend_service.lb_backend.self_link
    error_message = "backend_service should output the backend service self link."
  }

  assert {
    condition     = length(output.forwarding_rules) == 2
    error_message = "forwarding_rules should list the primary and the extra rule."
  }
}

run "eleven_ports_split_five_five_one" {
  command = apply

  variables {
    ports = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
  }

  assert {
    condition     = length(google_compute_forwarding_rule.forwarding_rule_extra) == 2
    error_message = "Eleven ports should create two extra rules."
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule_extra[0].ports == toset(["6", "7", "8", "9", "10"])
    error_message = "The first extra rule should carry ports six to ten."
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule_extra[1].ports == toset(["11"])
    error_message = "The second extra rule should carry the eleventh port."
  }

  assert {
    condition     = google_compute_forwarding_rule.forwarding_rule_extra[1].name == "forwarding-rule-dev-app-3"
    error_message = "The second extra rule should be named with a -3 suffix."
  }
}

run "internal_scheme_rejects_more_than_five_ports" {
  command = plan

  variables {
    load_balancing_scheme = "INTERNAL"
    address_type          = "INTERNAL"
    ports                 = ["1", "2", "3", "4", "5", "6"]
  }

  expect_failures = [
    google_compute_forwarding_rule.forwarding_rule_extra,
  ]
}

run "empty_ports_are_rejected" {
  command = plan

  variables {
    ports = []
  }

  expect_failures = [
    var.ports,
  ]
}
