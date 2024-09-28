data "google_compute_image" "my_image" {
  #Debian
  project = "debian-cloud"
  family  = "debian-12"
}

# Boot Disk
resource "google_compute_disk" "blog_vm_boot" {
  name  = "blog-vm-boot"
  type  = "pd-ssd"
  zone  = var.zones[0]
  image = data.google_compute_image.my_image.self_link
  labels = {
    environment = local.environment
  }
  size = 20
}
# Instance blog-vm
resource "google_compute_instance" "blog_vm" {
  name         = "${local.name}-blog-vm"
  description  = "Blog instance"
  tags         = [tolist(google_compute_firewall.allow_ssh.target_tags)[0], tolist(google_compute_firewall.allow_http.target_tags)[0]]
  machine_type = var.machine_type
  zone         = var.zones[0]
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  labels = {
    environment = local.environment
  }

  boot_disk {
    source      = google_compute_disk.blog_vm_boot.self_link
    auto_delete = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.gce_subnet.id
    access_config {
      // Ephemeral public IP
    }
  }
  # Install Webserver
  metadata_startup_script = file("${path.module}/scripts/setup-blog-nginx.sh") 

  metadata = {
    environment             = local.environment
  }
  service_account {
    email  = google_service_account.blog_vm_sa.email
    scopes = ["cloud-platform"]
  }
}
