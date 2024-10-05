# Create a GCS bucket
resource "google_storage_bucket" "public_bucket" {
  name          = "${var.project_id}-bucket"
  location      = var.region
  force_destroy = true

  labels = {
    environment = "dev"
    purpose     = "web-files"
  }
}

# Upload two files to the bucket with public access
resource "google_storage_bucket_object" "file1" {
  name         = "blog.html"
  bucket       = google_storage_bucket.public_bucket.name
  source       = "scripts/blog.html"
  content_type = "text/html"
}

resource "google_storage_bucket_object" "file2" {
  name         = "my-dog.jpg"
  bucket       = google_storage_bucket.public_bucket.name
  source       = "scripts/my-dog.jpg"
  content_type = "image/jpeg"
}

# Add bucket-level access control to allow public access
resource "google_storage_bucket_iam_binding" "bucket_public_access" {
  bucket = google_storage_bucket.public_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}
