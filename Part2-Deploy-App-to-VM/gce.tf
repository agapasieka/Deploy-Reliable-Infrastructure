data "google_compute_image" "my_image" {
  #Debian
  project = "debian-cloud"
  family  = "debian-12"
}

# Regional Instance Template
resource "google_compute_instance" "blog_vm" {
  name         = "${local.name}-blog-vm"
  description  = "Blog instance"
  tags         = [tolist(google_compute_firewall.allow_ssh.target_tags)[0], tolist(google_compute_firewall.allow_http.target_tags)[0]]
  machine_type = var.machine_type
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

 labels = {
    environment = local.environment
  }

  boot_disk {
    source      = data.google_compute_image.my_image.self_link
    auto_delete = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mysubnet.id
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    metadata_startup_script = file("${path.module}/setup-blog-nginx.sh")  # Install Webserver
    environment             = local.environment
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.blog_vm_sa.email
    scopes = ["cloud-platform"]
  }
}