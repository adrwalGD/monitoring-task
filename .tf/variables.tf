variable "grafana_login" {
  description = "Grafana login"
  default     = "admin"
  sensitive   = true
}

variable "grafana_password" {
  description = "Grafana password"
  default     = "admin"
  sensitive   = true
}

variable "grafana_url" {
  description = "Grafana URL"
  default     = "http://localhost:3000"
}

variable "prometheus_url" {
  description = "Prometheus URL"
  default     = "http://localhost:9090"
}
