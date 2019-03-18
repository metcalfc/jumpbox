variable "username" {}
variable "dns_domain" {}

provider "digitalocean" {}

resource "digitalocean_ssh_key" "default" {
  name       = "Default SSH"
  public_key = "${file("/Users/${var.username}/.ssh/id_rsa.pub")}"
}

resource "digitalocean_droplet" "jumpbox" {
  image      = "ubuntu-18-04-x64"
  name       = "jumpbox"
  region     = "sfo2"
  size       = "s-1vcpu-1gb"
  ipv6       = true
  monitoring = true
  ssh_keys   = ["${digitalocean_ssh_key.default.fingerprint}"]
}

# create a firewall that only accepts port 80 traffic from the load balancer
resource "digitalocean_firewall" "default" {
  name = "default"

  droplet_ids = [
    "${digitalocean_droplet.jumpbox.id}",
  ]

  inbound_rule = [
    {
      protocol         = "udp"
      port_range       = "60001"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "udp"
      port_range       = "1194"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_domain" "default" {
  name = "${var.dns_domain}"
}

# Add a record to the domain
resource "digitalocean_record" "jumpbox_v4" {
  domain = "${digitalocean_domain.default.name}"
  type   = "A"
  name   = "jumpbox"
  value  = "${digitalocean_droplet.jumpbox.ipv4_address}"
  ttl    = 300
}

resource "digitalocean_record" "jumpbox_v6" {
  domain = "${digitalocean_domain.default.name}"
  type   = "AAAA"
  name   = "jumpbox"
  value  = "${digitalocean_droplet.jumpbox.ipv6_address}"
  ttl    = 300
}

# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = ["digitalocean_droplet.jumpbox"]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.jumpbox.name} ansible_host=${digitalocean_droplet.jumpbox.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3 username=${var.username}' > inventory"
  }
}
