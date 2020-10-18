variable "project_id" {
  type    = string
  default = null
}

variable "availability_zone" {
  type    = string
  default = "us-central1-a"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "vm_name" {
  type    = string
  default = "ipad-cloud"
}

variable "tailscale_key" {
  type    = string
  default = ""
}
