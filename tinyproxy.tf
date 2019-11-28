terraform {
  required_providers {
    hcloud = ">= 1.15"
    cloudflare = ">= 2.1"
    local = ">= 1.4"
  }
}

variable "server_name" {
  description = "The name of the server as specified when creating a server in Hetzner Cloud."
}
variable "server_type" {
  default = "cx11"
  description = "The Hetzner Cloud server type name. Possible values can be found using 'hcloud server-type list' using the hcloud CLI tool."
}
variable "dns_zone" {
  description = "The DNS zone where the DNS record will be created. E.g. 'example.com'."
}
variable "dns_host" {
  default = ""
  description = "The DNS host name for the record that will be created. The default value is server_name. E.g. if dns_host is 'my-server' then the FQDN will be 'my-server.example.com'"
}
variable "dns_ttl" {
  default = 300
  description = "The TTL value in seconds of the DNS record that will be created."
}
variable "ssh_key_names" {
  type = list(string)
  description = "The list of SSH key names of the keys that will be installed in the server. The keys must be created in Hetzner Cloud beforehand."
}

data "local_file" "user_data" {
  filename = "${path.module}/user-data.yaml"
}
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
  user_data = data.local_file.user_data.content
}
resource "cloudflare_record" "tinyproxy_host" {
  name = var.dns_host == "" ? var.server_name : var.dns_host
  type = "A"
  zone_id = data.cloudflare_zones.target_zone.zones[0].id
  proxied = false
  ttl = var.dns_ttl
  value = hcloud_server.tinyproxy_host.ipv4_address
}

output "server" {
  value = hcloud_server.tinyproxy_host
}
output "cloudflare_record" {
  value = cloudflare_record.tinyproxy_host
}
