variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the VM in."
  type        = string
}

variable "subnet_id" {
  description = "Subnet the NIC attaches to."
  type        = string
}

variable "vm_size" {
  description = "VM size."
  type        = string
}

variable "admin_username" {
  description = "Admin user on the VM."
  type        = string
}

variable "ssh_public_key" {
  description = "Contents of the SSH public key."
  type        = string
}

variable "custom_data" {
  description = "Base64-encoded cloud-init data."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for all resources."
  type        = map(string)
  default     = {}
}
