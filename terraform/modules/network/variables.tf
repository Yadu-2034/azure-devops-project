variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the network in."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space of the VNet."
  type        = list(string)
}

variable "subnet_prefix" {
  description = "CIDR of the subnet."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Source CIDR allowed to SSH."
  type        = string
}

variable "tags" {
  description = "Tags for all resources."
  type        = map(string)
  default     = {}
}
