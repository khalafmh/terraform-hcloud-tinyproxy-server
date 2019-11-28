output "server" {
  value = hcloud_server.tinyproxy_host
}
output "cloudflare_record" {
  value = cloudflare_record.tinyproxy_host
}
