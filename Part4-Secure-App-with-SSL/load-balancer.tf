# Reserve Static IP Address
resource "google_compute_global_address" "mylb" {
  name = "${local.name}-mylb-static-ip"
}

# Health Check
resource "google_compute_health_check" "mylb" {
  name                = "${local.name}-mylb-blog-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  http_health_check {
    request_path = "/index.html"
    port         = 80
  }
}

# Backend Service
resource "google_compute_backend_service" "mylb" {
  name                  = "${local.name}-blog-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.mylb.self_link]
  port_name             = "webserver"
  backend {
    group           = google_compute_instance_group_manager.blog_mig.instance_group
    capacity_scaler = 1.0
    balancing_mode  = "UTILIZATION"
  }
}

# URL Map
resource "google_compute_url_map" "mylb" {
  name            = "${local.name}-mylb-url-map"
  default_service = google_compute_backend_service.mylb.self_link
}

# URL Map for HTTP to HTTPS redirection
resource "google_compute_url_map" "http" {
  name = "${local.name}-blog-http-to-https-url-map"
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "mylb" {
  name    = "${local.name}-mylb-http-proxy"
  url_map = google_compute_url_map.http.self_link ## Modify in Step2/Task4
}

# HTTPS Target Proxy
resource "google_compute_target_https_proxy" "mylb" {
  name             = "${local.name}-mylb-https-proxy"
  url_map          = google_compute_url_map.mylb.self_link
  ssl_certificates = [google_compute_ssl_certificate.blog_ssl.id]
}

# HTTP Forwarding Rule
resource "google_compute_global_forwarding_rule" "mylb" {
  name                  = "${local.name}-mylb-forwarding-rule"
  target                = google_compute_target_http_proxy.mylb.self_link
  port_range            = "80"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED"

  depends_on = [google_compute_subnetwork.regional_proxy_subnet]
}

# HTTPS Forwarding Rule
resource "google_compute_forwarding_rule" "mylb_https" {
  name                  = "${local.name}-mylb-https-forwarding-rule"
  target                = google_compute_target_https_proxy.mylb.self_link
  port_range            = "443"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.mylb.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network               = google_compute_network.myvpc.id

  depends_on = [google_compute_subnetwork.regional_proxy_subnet]
}

output "Load_Balancer_IP" {
  value       = google_compute_global_address.mylb.address
  description = "The external IP address of the Load Balancer"
}
