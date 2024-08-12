variable "project_id" {
  description = "The project ID to create the resource in."
}

variable "description" {
  description = "Common description for all load balancer resources"
  default     = null
}

variable "region" {
  description = "All resources will be launched in this region"
}

variable "service_name" {
  type        = string
  description = "service name for the load balancer like vdp or sm"
}

variable "env" {
  type        = string
  description = "environment of the project"
}

variable "ip_protocol" {
  type        = string
  description = "The IP protocol to which this rule applies"
  default     = "TCP"
}

variable "reserve_ip_address" {
  description = "set true to reserve ip and use this ip address to create forwarding rule"
  type        = bool
  default     = false
}

variable "load_balancing_scheme" {
  type        = string
  default     = "INTERNAL"
  description = "Specifies the forwarding rule type.Default value is INTERNAL. Possible values are: EXTERNAL, EXTERNAL_MANAGED, INTERNAL, INTERNAL_MANAGED"
  validation {
    condition     = contains(["EXTERNAL", "EXTERNAL_MANAGED", "INTERNAL", "INTERNAL_MANAGED"], var.load_balancing_scheme)
    error_message = "load balancing scheme must be of: \"EXTERNAL\", \"EXTERNAL_MANAGED\", \"INTERNAL\", \"INTERNAL_MANAGED\"."
  }
}

variable "allow_global_access" {
  type        = bool
  default     = false
  description = "This field is used along with the backend_service field for internal load balancing or with the target field for internal TargetInstance."
}

variable "ports" {
  type        = list(string)
  default     = ["80"]
  description = "Only packets addressed to these ports will be forwarded to the backends configured with this forwarding rule."
}

variable "protocol" {
  type        = string
  default     = "TCP"
  description = " The protocol this BackendService uses to communicate with backends. Default is TCP.Possible values are: HTTP, HTTPS, HTTP2, TCP, SSL, GRPC"
  validation {
    condition     = contains(["HTTP", "HTTPS", "HTTP2", "TCP", "SSL", "GRPC"], var.protocol)
    error_message = "Protocol must be of: \"HTTP\", \"HTTPS\", \"HTTP2\", \"TCP\", \"SSL\", or \"GRPC\"."
  }
}

variable "affinity_cookie_ttl_sec" {
  type        = number
  default     = null
  description = " The maximum allowed value for TTL is one day. When the load balancing scheme is INTERNAL, this field is not used."
}

variable "connection_draining_timeout_sec" {
  type        = number
  default     = null
  description = "Time for which instance will be drained (not accept new connections, but still work to finish started)."
}

variable "timeout_sec" {
  type        = number
  default     = null
  description = "How many seconds to wait for the backend before considering it a failed request. Valid range is [1, 86400]."
}

variable "enable_log_config" {
  type        = bool
  default     = true
  description = " If enable_log_config is enabled, logs will be exported to Stackdriver."
}

variable "sample_rate" {
  type        = string
  default     = "1.0"
  description = "This field can only be specified if logging is enabled for this backend service. The value of the field must be in [0, 1]. This configures the sampling rate of requests to the load balancer where 1.0 means all logged requests are reported and 0.0 means no logged requests are reported. The default value is 1.0."
}

variable "http_health_check" {
  type        = bool
  default     = false
  description = "If true, health check type http is enabled"
}

variable "tcp_health_check" {
  type        = bool
  default     = true
  description = "If true, health check type tcp is enabled"
}

variable "group_url" {
  type        = string
  description = "The fully-qualified URL of an Instance Group or Network Endpoint Group resource."
}

variable "additional_backends" {
  default     = []
  description = "additional backend group, description, balancing mode"
}

variable "backend_description" {
  type        = string
  default     = "Instance Group for INTERNAL LB"
  description = " description of the backend resource. Provide this property when you create the resource."
}

variable "balancing_mode" {
  type        = string
  default     = "UTILIZATION"
  description = "Specifies the balancing mode for this backend. Default value is UTILIZATION. Possible values are: UTILIZATION, RATE, CONNECTION"
  validation {
    condition     = contains(["UTILIZATION", "RATE", "CONNECTION"], var.balancing_mode)
    error_message = "balancing mode must be of: \"UTILIZATION\", \"RATE\", \"CONNECTION\"."
  }
}

variable "network_tier" {
  type        = string
  default     = "PREMIUM"
  description = "This signifies the networking tier used for configuring this load balancer and can only take the following values: PREMIUM, STANDARD"
}

variable "network" {
  default     = "default"
  description = "VPC network in which to deploy the resources"
}

variable "subnetwork" {
  default     = ""
  description = "VPC subnetwork in which to deploy the resources"
}

variable "subnetwork_address" {
  default     = ""
  description = "VPC subnetwork in which to deploy the IP address for Internal Ips only"
}

variable "ip_address" {
  description = "IP address of the load balancer. If empty, an IP address will be automatically assigned"
  default     = null
}

variable "address_type" {
  description = "Reserved IP address type of the load balancer. If empty, possible values are INTERNAL, EXTERNAL"
  default     = ""
}

variable "is_mirroring_collector" {
  description = "Indicates whether or not this load balancer can be used as a collector for packet mirroring"
  type        = bool
  default     = false
}

variable "service_label" {
  description = "An optional prefix to the service name for this Forwarding Rule. If specified, will be the first label of the fully qualified service name"
  default     = null
  type        = string
}

variable "service_directory_registrations" {
  type = object({
    namespace = string
    service   = string
  })
  default     = null
  description = "Service Directory resources to register this forwarding rule with."
}

variable "session_affinity" {
  description = "The session affinity for the backends, eg: NONE, CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO, GENERATED_COOKIE, HEADER_FIELD, HTTP_COOKIE. default is NONE"
  default     = "NONE"
  validation {
    condition     = contains(["NONE", "CLIENT_IP", "CLIENT_IP_PORT_PROTO", "CLIENT_IP_PROTO", "GENERATED_COOKIE", "HEADER_FIELD", "HTTP_COOKIE"], var.session_affinity)
    error_message = "Session affinity must be of: NONE, CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO, GENERATED_COOKIE, HEADER_FIELD, HTTP_COOKIE."
  }
}

variable "check_interval_sec" {
  type        = number
  default     = 5
  description = "How often (in seconds) to send a health check. The default value is 5 seconds."
}

variable "hc_timeout_sec" {
  type        = number
  default     = 5
  description = "How long (in seconds) to wait before claiming failure. The default value is 5 seconds. It is invalid for timeoutSec to have greater value than checkIntervalSec."
}

variable "unhealthy_threshold" {
  type        = number
  default     = 2
  description = " A so-far healthy instance will be marked unhealthy after this many consecutive failures. The default value is 2."
}

variable "healthy_threshold" {
  type        = number
  default     = 2
  description = "A so-far unhealthy instance will be marked healthy after this many consecutive successes. The default value is 2."
}

variable "request" {
  type        = string
  default     = null
  description = "The application data to send once the TCP connection has been established (default value is empty)."
}

variable "response" {
  type        = string
  default     = null
  description = "The bytes to match against the beginning of the response data. If left empty (the default value), any response will indicate health. The response data can only be ASCII."
}

variable "hc_port" {
  type        = string
  description = " The TCP port number for the TCP health check request."
}

variable "port_specification" {
  type        = string
  default     = "USE_FIXED_PORT"
  description = "Specifies how port is selected for health checking.Default value is USE_FIXED_PORT. Possible values are: USE_FIXED_PORT, USE_NAMED_PORT, USE_SERVING_PORT"
}

variable "proxy_header" {
  type        = string
  default     = "NONE"
  description = " Specifies the type of proxy header to append before sending data to the backend. Default value is NONE. Possible values are: NONE, PROXY_V1"
}

variable "host" {
  type        = string
  default     = null
  description = "The value of the host header in the HTTP health check request. If left empty (default value), the public IP on behalf of which this health check is performed will be used."
}

variable "port_name" {
  type        = string
  default     = null
  description = "Port name as defined in InstanceGroup#NamedPort#name. If both port and port_name are defined, port takes precedence."
}