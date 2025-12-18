output "server_ipv4" {
  description = "Public IPv4 addresses of the build agents"
  value       = [for s in hcloud_server.agent : s.ipv4_address]
}

output "server_ipv6" {
  description = "Public IPv6 addresses of the build agents"
  value       = [for s in hcloud_server.agent : s.ipv6_address]
}

output "server_names" {
  description = "Server names"
  value       = [for s in hcloud_server.agent : s.name]
}
