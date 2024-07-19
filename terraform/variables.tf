# Common variables

variable "labels" {
  description = "common labels"
  type        = map(string)
  default = {
    Managed_by = "terraform"
    Project    = "fast-ovpn"
  }
}

variable "delete_protection" {
  description = "delete_protection"
  default     = false
}

# Master vars

variable "ovpn_server_type" {
  description = "ovpn_server_type. 'hcloud server-type list' for help"
  default     = "cx11"
}

variable "ovpn_server_image" {
  description = "ovpn_server immage. 'hcloud image list' for help"
  default     = "ubuntu-22.04"
}

