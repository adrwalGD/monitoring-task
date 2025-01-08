terraform {
  required_version = ">= 1.3.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "3.15.3"
    }
  }
}

provider "docker" {
}

provider "grafana" {
  url  = var.grafana_url
  auth = "${var.grafana_login}:${var.grafana_password}"
}


resource "docker_image" "grafana_image" {
  name         = "grafana/grafana-oss:latest"
  keep_locally = false
}

resource "docker_container" "grafana_container" {
  name         = "grafana"
  image        = docker_image.grafana_image.name
  network_mode = "host"
  ports {
    internal = 3000
    external = 3000
  }

  env = [
    "GF_SECURITY_ADMIN_USER=${var.grafana_login}",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_password}",
  ]
}

resource "grafana_data_source" "prometheus_ds" {
  depends_on = [
    docker_container.grafana_container
  ]
  uid        = "prometheus"
  name       = "Prometheus"
  type       = "prometheus"
  url        = var.prometheus_url
  is_default = true
}

resource "grafana_folder" "prometheus_folder" {
  title      = "Prometheus"
  depends_on = [docker_container.grafana_container, grafana_data_source.prometheus_ds]
}

resource "grafana_dashboard" "example_dashboard" {
  depends_on = [
    grafana_data_source.prometheus_ds
  ]

  folder      = grafana_folder.prometheus_folder.id
  config_json = file("${path.module}/dashboard.json")
}
