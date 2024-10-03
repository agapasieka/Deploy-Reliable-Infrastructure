# Add bucket-level access control to allow public access
resource "google_storage_bucket_iam_binding" "bucket_public_access" {
  bucket = google_storage_bucket.public_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}
