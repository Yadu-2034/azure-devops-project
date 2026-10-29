output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "vm_name" {
  description = "Name of the virtual machine."
  value       = module.compute.vm_name
}

output "public_ip_address" {
  description = "Public IP of the VM (put this in the Jenkins 'azure-vm-ip' credential)."
  value       = module.compute.public_ip_address
}

output "app_url" {
  description = "URL where the web app is served."
  value       = "http://${module.compute.public_ip_address}"
}

output "ssh_command" {
  description = "Command to SSH into the VM."
  value       = "ssh -i ~/.ssh/azure_vm_key ${var.admin_username}@${module.compute.public_ip_address}"
}
