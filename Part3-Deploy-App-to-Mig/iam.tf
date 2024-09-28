# Grant the service account permission to read objects in the buckets
resource "google_project_iam_member" "vm_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"

  member = "serviceAccount:${google_service_account.blog_vm_sa.email}"
}

# Add bucket-level access control to allow public access
resource "google_storage_bucket_iam_binding" "bucket_public_access" {
  bucket = google_storage_bucket.public_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}
