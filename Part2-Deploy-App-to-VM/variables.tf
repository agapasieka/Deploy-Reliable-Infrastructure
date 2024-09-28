# GCP Project
variable "project_id" {
  description = "Project ID"
  type        = string
}

# GCP Region
variable "region" {
  description = "main region"
  type        = string
}

# GCP Zones
variable "zones" {
  description = "Zones"
  type        = list(string)
}

# GCP Compute Engine Machine Type
variable "machine_type" {
  description = "Compute Engine Machine Type"
  type        = string
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
}