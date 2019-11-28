variable "server_name" {
  type = string
  description = "The name of the server as specified when creating a server in Hetzner Cloud."
}
variable "server_type" {
  type = string
  default = "cx11"
  description = "The Hetzner Cloud server type name. Possible values can be found using 'hcloud server-type list' using the hcloud CLI tool."
}
variable "dns_zone" {
  type = string
  description = "The DNS zone where the DNS record will be created. E.g. 'example.com'."
}
variable "dns_host" {
  type = string
  default = ""
  description = "The DNS host name for the record that will be created. The default value is server_name. E.g. if dns_host is 'my-server' then the FQDN will be 'my-server.example.com'"
}
variable "dns_ttl" {
  type = number
  default = 300
  description = "The TTL value in seconds of the DNS record that will be created."
}
variable "ssh_key_names" {
  type = list(string)
  description = "The list of SSH key names of the keys that will be installed in the server. The keys must be created in Hetzner Cloud beforehand."
}
