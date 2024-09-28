# VPC
resource "google_compute_network" "myvpc" {
  name                    = "${local.name}-vpc"
  auto_create_subnetworks = false
}

# Regional Subnet
resource "google_compute_subnetwork" "gce_subnet" {
  name          = "${var.region}-gce-subnet"
  region        = var.region
  ip_cidr_range = "10.128.0.0/20"
  network       = google_compute_network.myvpc.id
}

# Regional Proxy-Only Subnet 
resource "google_compute_subnetwork" "regional_proxy_subnet" {
  name          = "${var.region}-regional-proxy-subnet"
  region        = var.region
  ip_cidr_range = "10.0.0.0/24"
  purpose       = "REGIONAL_MANAGED_PROXY"
  network       = google_compute_network.myvpc.id
  role          = "ACTIVE"
}