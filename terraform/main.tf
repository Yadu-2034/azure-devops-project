locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags
  )
}

# 1. Resource Group ----------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# 2. Virtual Network + Subnet + Network Security Group ------------------------
module "network" {
  source = "./modules/network"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  vnet_address_space  = var.vnet_address_space
  subnet_prefix       = var.subnet_prefix
  allowed_ssh_cidr    = var.allowed_ssh_cidr
  tags                = local.common_tags
}

# 3. Public IP + Network Interface + Linux Virtual Machine --------------------
module "compute" {
  source = "./modules/compute"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.subnet_id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = file(pathexpand(var.ssh_public_key_path))
  custom_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {
    admin_username = var.admin_username
  }))
  tags = local.common_tags
}
