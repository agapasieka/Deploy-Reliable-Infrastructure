# Certificate manager 
resource "google_certificate_manager_certificate" "blog_ssl" {
  location    = var.region
  name        = "${local.name}-ssl-certificate"
  description = "${local.name} Certificate Manager SSL Certificate"
  scope       = "DEFAULT"
  self_managed {
    pem_certificate = file("${path.module}/self-signed-ssl/blog.crt")
    pem_private_key = file("${path.module}/self-signed-ssl/blog.key")
  }
  labels = {
    env = local.environment
  }
}