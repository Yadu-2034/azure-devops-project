output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  description = "ID of the subnet (consumed by the compute module)."
  value       = azurerm_subnet.subnet.id
}

output "nsg_id" {
  description = "ID of the network security group."
  value       = azurerm_network_security_group.nsg.id
}
