# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id            = "be868bd4-3bf7-4511-8065-c4a0917fa077"
  skip_provider_registration = true
}

terraform {
  backend "remote" {
    organization = "myshka"
    workspaces {
      name = "automation_platform"
    }
  }
}

resource "azurerm_resource_group" "automation_platform" {
  location = "eastus2"
  name     = "automation_platform"
  tags     = {}

  timeouts {}
}

resource "azurerm_virtual_network" "automation_platform_vnet" {
  address_space = [
    "10.0.0.0/16",
  ]
  location            = "eastus2"
  name                = "automation_platform-vnet"
  resource_group_name = azurerm_resource_group.automation_platform.name
}

resource "azurerm_subnet" "automation_platform_subnet" {
  address_prefixes = [
    "10.0.0.0/24",
  ]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
  name                                           = "default"
  resource_group_name                            = "automation_platform"
  virtual_network_name                           = "automation_platform-vnet"

  timeouts {}
}

resource "azurerm_network_interface" "automation_platform_nic" {
  enable_accelerated_networking = true
  location                      = "eastus2"
  name                          = "automation-platform-74"
  resource_group_name           = "automation_platform"
  tags                          = {}

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    private_ip_address            = "10.0.0.4"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = "/subscriptions/be868bd4-3bf7-4511-8065-c4a0917fa077/resourceGroups/automation_platform/providers/Microsoft.Network/publicIPAddresses/automation-platform-001-ip"
    subnet_id                     = "/subscriptions/be868bd4-3bf7-4511-8065-c4a0917fa077/resourceGroups/automation_platform/providers/Microsoft.Network/virtualNetworks/automation_platform-vnet/subnets/default"
  }

  timeouts {}
}

resource "azurerm_public_ip" "automation_platform_pub_001" {
  allocation_method       = "Dynamic"
  availability_zone       = "No-Zone"
  idle_timeout_in_minutes = 4
  ip_version              = "IPv4"
  location                = "eastus2"
  name                    = "automation-platform-001-ip"
  resource_group_name     = "automation_platform"
  sku                     = "Basic"
  timeouts {}
}

resource "azurerm_virtual_machine" "automation_platform_server" {
  location = "eastus2"
  name     = "automation-platform-001"
  network_interface_ids = [
    "/subscriptions/be868bd4-3bf7-4511-8065-c4a0917fa077/resourceGroups/automation_platform/providers/Microsoft.Network/networkInterfaces/automation-platform-74",
  ]
  resource_group_name = "automation_platform"
  tags                = {}
  vm_size             = "Standard_F4s_v2"
  zones               = []

  os_profile {
    admin_username = "myshka"
    computer_name  = "automation-platform-001"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYkRhLiUjnXr/zPP/guT6JjmoABR8OlrOh+W1sLXoT4xYMcBnhW3GUUkdKt0KC5pr7to7hrabZyD7ezJkYNZKq/huVFOTPanUzp6MPsq7/LhMtNY3efhfGV6nL0NTjIXxTlmhTBkwx2d8lmtOpc9bFJSa9MZLj2yAvuJmIz81l1YOztyOlGUhJ3znm2SlpWpJHZAKYSr1GvMZa5Nkq21Fl/Xa7JbNOuf3Vn/jG3xOS8UcxTG5RSGO+BniDht+eHeU84AwIRp98xiWsGy2ppTMoAicfaQimku1EimgJcpuQ+hPWNxm3CnDG0RhbP23ENFWMoQBtJ7aTOMXUwowd2Q3P1+K1dz8sgoyzuiAsN1/6UFMTcFIZjj00x5J+YWEEjxnPp2k1DPY2VxoWz70GYz8GKjDdxcuWuq1MIkJ9Ihr9Y6g7tfHBRF+YWQwlmA2sGd7LZ9Br6mF2DYPpi9PSt+4Hb+F1zWLJLU/lUW2gQJHJ3QsiIXdJsi9jJDCFMFhHOHU= root@DESKTOP-A4E80TV"
      path     = "/home/myshka/.ssh/authorized_keys"
    }
  }

  storage_image_reference {
    offer     = "RHEL"
    publisher = "RedHat"
    sku       = "8_4"
    version   = "latest"
  }

  storage_os_disk {
    caching                   = "ReadWrite"
    create_option             = "FromImage"
    disk_size_gb              = 64
    managed_disk_id           = "/subscriptions/be868bd4-3bf7-4511-8065-c4a0917fa077/resourceGroups/automation_platform/providers/Microsoft.Compute/disks/automation-platform-001_OsDisk_1_892185b34347448b87e9fa45f35cf0f0"
    managed_disk_type         = "StandardSSD_LRS"
    name                      = "automation-platform-001_OsDisk_1_892185b34347448b87e9fa45f35cf0f0"
    os_type                   = "Linux"
    write_accelerator_enabled = false
  }

  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true

  timeouts {}
}