output "ovpn_hosts" {
  description = "Ovpn endpoints to SSH to"
  value = {
    control_plane = {
      hostnames      = hcloud_server.controller.name
      public_address = hcloud_server.controller.ipv4_address
    }
  }
}

output "ovpn_host_ssh_private_key" {
  sensitive = true
  description = "SSH keys info"
  value = tls_private_key.ssh_key.private_key_openssh
}
