resource "google_project_service" "cert_manager_api" {
  service             = "certificatemanager.googleapis.com"
  disable_on_destroy  = false 
}

# SSL Certificate
resource "google_compute_ssl_certificate" "blog_ssl" {
  name_prefix = "blog-ssl-"
  description = "SSL Certificate for blog"
  private_key = file("self-signed-ssl/blog.key")
  certificate = file("self-signed-ssl/blog.crt")

  lifecycle {
    create_before_destroy = true
  }
}
