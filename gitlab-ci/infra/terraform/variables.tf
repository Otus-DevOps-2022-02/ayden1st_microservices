variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  default     = "ru-central1-a"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable "bucket_name" {
  description = "Storage bucket name"
}
variable "storage_key" {
  description = "Storage key_id"
}
variable "storage_secret" {
  description = "Storage secret"
}
variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "gitlab_disk_image" {
  description = "Disk image for gitlab"
  default     = "ubuntu-1804-lts"
}
