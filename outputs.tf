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

output "azure_agent_pool" {
  description = "Azure DevOps agent pool managed by this configuration"
  value       = azuredevops_agent_pool.this.name
}

output "azure_project_name" {
  description = "Azure DevOps project where the queue is authorized"
  value       = data.azuredevops_project.this.name
}

output "azure_agent_queue_id" {
  description = "Azure DevOps project queue ID authorized for pipelines"
  value       = azuredevops_agent_queue.this.id
}
