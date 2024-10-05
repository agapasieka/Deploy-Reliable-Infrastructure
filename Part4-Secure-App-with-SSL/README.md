<!-- Overview -->
# Overview
Secure blog with SSL Certificate. For simplicity, we will create self-signed SSL certificate and attach it to HTTP(S) Load Balancer we created in previous part. We wil also store certificate in Google Certificate Manager.

<!-- Task1 -->
## Deploy infrastructure
1. Clone repo with config code
  ```sh
git clone https://github.com/agapasieka/Deploy-Reliable-Infrastructure.git
  ```
We will start with generating certificate

2. Change directory 
  ```sh
  cd Deploy-Reliable-Infrastructure/Part4-Secure-App-with-SSL/self-signed-ssl
  ```
3. Create private key
  ```sh
  openssl genrsa -out blog.key 2048
  ``` 
4. Create certificate signing request
  ```sh
  openssl req -new -key blog.key -out blog.csr -subj "/CN=blog.example.com"
  ``` 
5. Create public certificate
  ```sh
  openssl x509 -req -days 7300 -in blog.csr -signkey blog.key -out blog.crt
  cd ..
  ``` 
6. Create Certificate in Certificate Manager
  ```sh
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
  ```
OPTIONAL: Use can also deploy the certificate using Terraform. Create tls.tf with the folowing example config
  ```sh
      # Self-signed regional SSL certificate for testing
    resource "tls_private_key" "default" {
      algorithm = "RSA"
      rsa_bits  = 2048
    }

    resource "tls_self_signed_cert" "default" {
      private_key_pem = tls_private_key.default.private_key_pem

      # Certificate expires after 12 hours.
      validity_period_hours = 12

      # Generate a new certificate if Terraform is run within three
      # hours of the certificate's expiration time.
      early_renewal_hours = 3

      # Reasonable set of uses for a server SSL certificate.
      allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
      ]

      dns_names = ["example.com"]

      subject {
        common_name  = "example.com"
        organization = "ACME Examples, Inc"
      }
    }

    resource "google_compute_ssl_certificate" "default" {
      name        = "default-cert"
      private_key = tls_private_key.default.private_key_pem
      certificate = tls_self_signed_cert.default.cert_pem
    }
  ```
7. Create HTTPS Proxy in load-balander.tf
  ```sh
  resource "google_compute_region_target_https_proxy" "mylb" {
    name   = "${local.name}-mylb-https-proxy"
    url_map = google_compute_region_url_map.mylb.self_link
    certificate_manager_certificates = [ google_certificate_manager_certificate.blog_ssl.id ]
  }
  ```
8. Create Regional Forwarding rule for HTTPS
  ```sh
    # Regional HTTPS Forwarding Rule
  resource "google_compute_forwarding_rule" "mylb_https" {
      name        = "${local.name}-mylb-https-forwarding-rule"
      target      = google_compute_region_target_https_proxy.mylb.self_link
      port_range  = "443"
      ip_protocol = "TCP"
      ip_address = google_compute_address.mylb.address
      load_balancing_scheme = "EXTERNAL_MANAGED" 
      network = google_compute_network.myvpc.id
      
      depends_on = [ google_compute_subnetwork.regional_proxy_subnet ]
    }
  ```  
9. Setup http-to-https redirection. Add RL Map for HTTP to HTTPS redirection in load-balancer.tf
  ```sh
    # Regional URL Map for HTTP to HTTPS redirection
  resource "google_compute_region_url_map" "http" {
    name = "${local.name}-blog-http-to-https-url-map"
    default_url_redirect {
      redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
      strip_query            = false
      https_redirect         = true
    }
  }
  ```
10. Modify the Regional HTTP Proxy to use the new URL Map for HTTP to HTTPS redirection. It should looks like this
  ```sh
    # Regional HTTP Proxy
  resource "google_compute_region_target_http_proxy" "mylb" {
    name    = "${local.name}-mylb-http-proxy"
    url_map = google_compute_region_url_map.http.self_link
  }
    ```

11. Initialise Terraform and apply the configuration 
  ```sh
  terraform init
  terraform apply -auro-approve
  ``` 
You will be prompted to enter Project ID.

When deployment completes, terraform outputs the external IP of load balancer. You can test the blog in browser by using the following URL
  ```sh
  https://<LOAD-BALANCER-IP>
  ```

<!-- Task3 -->
## Lab Clean-up
  ```sh
  terraform destroy
  ```
