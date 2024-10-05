# Managed Instance Group
resource "google_compute_instance_group_manager" "blog_mig" {
  name                      = "${local.name}-blog-mig"
  base_instance_name        = "${local.name}-blog"
  target_size  = 2
  zone = var.zones[0]

  version {
    instance_template = google_compute_instance_template.blog_green.id
  }
  # Named Port
  named_port {
    name = "webserver"
    port = 80
  }
  # Autohealing
  auto_healing_policies {
    health_check      = google_compute_health_check.blog_hc.id
    initial_delay_sec = 300
  }
  # Update Policy
  update_policy {
    type                           = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = length(var.zones)
    max_unavailable_fixed          = length(var.zones)
    replacement_method             = "SUBSTITUTE"
  }
depends_on = [google_storage_bucket.public_bucket, google_storage_bucket_object.file1, google_storage_bucket_object.file2]
}

# Health Check
resource "google_compute_health_check" "blog_hc" {
  name                = "${local.name}-blog-hc"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    request_path = "/index.html"
    port         = 80
  }
}

# MIG Autoscaling
resource "google_compute_autoscaler" "blog_autoscaler" {
  name   = "${local.name}-blog-autoscaler"
  zone   = var.zones[0]
  target = google_compute_instance_group_manager.blog_mig.id
  autoscaling_policy {
    max_replicas    = 6
    min_replicas    = 2
    cooldown_period = 60
    cpu_utilization {
      target = 0.9
    }
  }
}


