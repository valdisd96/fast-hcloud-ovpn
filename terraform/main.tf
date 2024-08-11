data "external" "my_ip" {
  program = ["bash", "get_external_ip.sh"]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "primary-ssh-key" {
  name       = "${var.labels["Project"]}-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "hcloud_firewall" "cluster" {
  name = "${var.labels["Project"]}-fw"

  labels = var.labels

  apply_to {
    label_selector = "Project=${var.labels["Project"]}"
  }

   rule {
    description = "allow all TCP inside cluster"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips = [
      "${data.external.my_ip.result.ip}/32",
    ]
  }

  rule {
    description = "allow all UDP inside cluster"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips = [
      "${data.external.my_ip.result.ip}/32",
    ]
  }

}

resource "hcloud_server" "controller" {
  name               = "${var.labels["Project"]}-master"
  server_type        = var.ovpn_server_type
  image              = var.ovpn_server_image
  ssh_keys           = [hcloud_ssh_key.primary-ssh-key.name]
  delete_protection  = var.delete_protection
  labels             = var.labels
}
