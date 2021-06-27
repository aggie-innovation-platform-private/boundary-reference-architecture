# Define provider for config
provider "azurerm" {
  features {}
}

# Used to get tenant ID as needed
data "azurerm_client_config" "current" {}

# Resource group for ALL resources
resource "azurerm_resource_group" "boundary" {
  name     = local.resource_group_name
  location = var.location
}

# Virtual network with three subnets for controller, workers, and backends
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.boundary.name
  vnet_name           = azurerm_resource_group.boundary.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  # Service endpoints used for Key Vault and Postgres DB access
  # Only the controller subnet needs DB access
  subnet_service_endpoints = {
    (var.subnet_names[0]) = ["Microsoft.KeyVault", "Microsoft.Sql"]
    (var.subnet_names[1]) = ["Microsoft.KeyVault"]
  }
}

# Create Network Security Groups for subnets
resource "azurerm_network_security_group" "controller_net" {
  name                = local.controller_net_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_network_security_group" "worker_net" {
  name                = local.worker_net_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_network_security_group" "backend_net" {
  name                = local.backend_net_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

# Create NSG associations
resource "azurerm_subnet_network_security_group_association" "controller" {
  subnet_id                 = module.vnet.vnet_subnets[0]
  network_security_group_id = azurerm_network_security_group.controller_net.id
}

resource "azurerm_subnet_network_security_group_association" "worker" {
  subnet_id                 = module.vnet.vnet_subnets[1]
  network_security_group_id = azurerm_network_security_group.worker_net.id
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = module.vnet.vnet_subnets[2]
  network_security_group_id = azurerm_network_security_group.backend_net.id
}

# Create Network Security Groups for NICs
# The associations are in the vm.tf file and remotehosts.tf file

resource "azurerm_network_security_group" "controller_nics" {
  name                = local.controller_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_network_security_group" "worker_nics" {
  name                = local.worker_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_network_security_group" "backend_nics" {
  name                = local.backend_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

# Create application security groups for controllers, workers, and backend
# The associations are in the vm.tf file and remotehosts.tf file

resource "azurerm_application_security_group" "controller_asg" {
  name                = local.controller_asg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_application_security_group" "worker_asg" {
  name                = local.worker_asg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_application_security_group" "backend_asg" {
  name                = local.backend_asg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}


data "azurerm_resource_group" "rg-aip-vpn-hub" {
  //provider = azurerm.aip-azure-hub
  name = "ExpressRouteGateway"
}


data "azurerm_virtual_network" "vnet-aip-vpn-hub" {
  //provider            = azurerm.aip-azure-hub
  name                = "AIP-VPN-Hub"
  resource_group_name = "ExpressRouteGateway"
}


resource "azurerm_virtual_network_peering" "boundary-to-hub-peer" {
  //provider = azurerm.engineering-prod
  name                      = "aip-peering-from-vnet-boundary-to-AIP-VPN-Hub"
  resource_group_name       = azurerm_resource_group.boundary.name
  virtual_network_name      = module.vnet.vnet_name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet-aip-vpn-hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  //depends_on                   = [azurerm_virtual_network.vnet-engineering-prod, data.azurerm_virtual_network.vnet-aip-vpn-hub, data.azurerm_virtual_network_gateway.gw-vnet-aip-vpn-hub]
  depends_on = [module.vnet.vnet_name, data.azurerm_virtual_network.vnet-aip-vpn-hub]
}

resource "azurerm_virtual_network_peering" "hub-to-boundary-peer" {
  //provider                     = azurerm.aip-azure-hub
  name                         = "aip-peering-from-AIP-VPN-Hub-to-vnet-boundary"
  resource_group_name          = data.azurerm_resource_group.rg-aip-vpn-hub.name
  virtual_network_name         = data.azurerm_virtual_network.vnet-aip-vpn-hub.name
  remote_virtual_network_id    = module.vnet.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  //depends_on                   = [azurerm_virtual_network.vnet-engineering-prod, data.azurerm_virtual_network.vnet-aip-vpn-hub, data.azurerm_virtual_network_gateway.gw-vnet-aip-vpn-hub]
  depends_on = [module.vnet.vnet_name, data.azurerm_virtual_network.vnet-aip-vpn-hub]
}
