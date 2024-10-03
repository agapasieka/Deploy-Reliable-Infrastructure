# Allow HTTP from Proxy-only subnet to backends
resource "google_compute_firewall" "allow_http" {
  name = "${local.name}-fwrule-allow-http80"
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.myvpc.id
  priority      = 1000
  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["webserver-tag"]
}

# Allow Health checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${local.name}-allow-health-checks"
  network = google_compute_network.myvpc.id
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  target_tags = ["allow-health-checks"]
}
