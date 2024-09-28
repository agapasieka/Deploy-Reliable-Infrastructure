# Create a GCS bucket
resource "google_storage_bucket" "public_bucket" {
  name         = var.project_id  
  location      = "EU"
  force_destroy = true

  labels = {
    environment = "dev"
    purpose     = "web-files"
  }
}

# Upload two files to the bucket with public access
resource "google_storage_bucket_object" "file1" {
  name   = "blog.html"   # Name of the file in the bucket
  bucket = google_storage_bucket.public_bucket.name
  source = "blog.html"   # Path to the local file
  content_type = "text/html"
}

resource "google_storage_bucket_object" "file2" {
  name   = "my-dog.jpg"  # Name of the file in the bucket
  bucket = google_storage_bucket.public_bucket.name
  source = "my-dog.jpg"  # Path to the local file
  content_type = "image/jpeg"
}
