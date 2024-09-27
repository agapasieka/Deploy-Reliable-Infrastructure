resource "google_service_account" "blog_vm_sa" {
  account_id   = "blog-vm-sa"
  display_name = "Custom SA for VM Instance"
}
