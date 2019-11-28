terraform {
  required_providers {
    hcloud = ">= 1.15"
    cloudflare = ">= 2.1"
    local = "~> 1.4"
  }
}

provider "local" {}

data "cloudflare_zones" "target_zone" {
  filter {
    name = var.dns_zone
  }
}

resource "hcloud_server" "tinyproxy_host" {
  image = "ubuntu-18.04"
  name = "${var.server_name}.${data.cloudflare_zones.target_zone.zones[0].name}"
  server_type = var.server_type
  ssh_keys = var.ssh_key_names
  user_data = <<EOT
    #cloud-config
    packages:
      - "docker.io"
    runcmd:
      - [docker, run, -d, --name, tinyproxy, --restart, always, -p, '8888:8888', dannydirect/tinyproxy, ANY]
  EOT
}
resource "cloudflare_record" "tinyproxy_host" {
  name = var.dns_host == "" ? var.server_name : var.dns_host
  type = "A"
  zone_id = data.cloudflare_zones.target_zone.zones[0].id
  proxied = false
  ttl = var.dns_ttl
  value = hcloud_server.tinyproxy_host.ipv4_address
}
