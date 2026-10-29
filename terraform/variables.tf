variable "project_name" {
  description = "Short name used as a prefix for every Azure resource."
  type        = string
  default     = "webappcicd"

  validation {
    condition     = can(regex("^[a-z0-9]{3,20}$", var.project_name))
    error_message = "project_name must be 3-20 lowercase letters/digits."
  }
}

variable "environment" {
  description = "Environment name (dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region. If you get a SKU / quota error, try another region (e.g. southindia, eastus, westeurope)."
  type        = string
  default     = "centralindia"
}

variable "vnet_address_space" {
  description = "Address space of the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "CIDR of the subnet that hosts the VM."
  type        = string
  default     = "10.0.1.0/24"
}

variable "vm_size" {
  description = "Azure VM size. Standard_B1s is cheapest; use Standard_B2s if B1s is unavailable."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux admin user on the VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key injected into the VM."
  type        = string
  default     = "~/.ssh/azure_vm_key.pub"
}

variable "allowed_ssh_cidr" {
  description = "Source CIDR allowed to SSH to the VM. '*' = anywhere (OK for a demo, restrict in real life)."
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
