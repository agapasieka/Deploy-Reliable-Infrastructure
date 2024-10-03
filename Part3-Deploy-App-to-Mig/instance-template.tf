data "google_compute_image" "my_image" {
  #Debian
  project = "debian-cloud"
  family  = "debian-12"
}

# Instance Template
resource "google_compute_instance_template" "blog_green" {
  name         = "${local.name}-blog-template"
  description  = "This template is used to create Blog instances."
  tags         = [tolist(google_compute_firewall.allow_http.target_tags)[0], tolist(google_compute_firewall.allow_health_checks.target_tags)[0]]
  machine_type = var.machine_type
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

   disk {
    source_image      = data.google_compute_image.my_image.self_link
    boot              = true
    auto_delete = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.gce_subnet.id
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/scripts/setup-blog-nginx.sh")

  metadata = {
    environment = local.environment
  }
  service_account {
    email  = google_service_account.blog_vm_sa.email
    scopes = ["cloud-platform"]
  }
}
