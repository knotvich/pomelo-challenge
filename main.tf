# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = "~> 0.14"

  backend "remote" {
    organization = "pomelo-challenge"

    workspaces {
      name = "pomelo-challenge-gh-actions"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "southeastasia"
  tags = {
    env  = "staging"
    team = "devops"
  }

}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = [var.virtual_network_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.virtual_network_default_subnet]
}

resource "azurerm_nat_gateway" "main" {
  name                    = "${var.prefix}-nat-gatway"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  public_ip_prefix_ids    = [azurerm_public_ip_prefix.nat.id]
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_public_ip" "nat" {
  name                = "${var.prefix}-nat-gateway-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_public_ip_prefix" "nat" {
  name                = "${var.prefix}-nat-gateway-public-ip-prefix"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  prefix_length       = 30
  zones               = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "web" {
  nat_gateway_id = azurerm_nat_gateway.main.id
  subnet_id      = azurerm_subnet.web.id
}

resource "azurerm_route_table" "main" {
  name                          = "${var.prefix}-route-table"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "internet"
  }

  tags = {
    env = "staging"
  }
}

resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = azurerm_subnet.web.id
  route_table_id = azurerm_route_table.main.id
}

resource "azurerm_public_ip" "web" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "http_rule" {
  name                        = "http"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "https_rule" {
  name                        = "https"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "web_rule" {
  name                        = "web"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}



resource "azurerm_subnet" "web" {
  name                 = "${var.prefix}-web-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "private-ip"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_attach" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_linux_virtual_machine" "web" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  computer_name       = "${var.prefix}-vm"
  admin_username      = "${var.prefix}-admin"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "${var.prefix}-admin"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storageaccount_log.primary_blob_endpoint
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  connection {
    host        = self.public_ip_address
    type        = "ssh"
    user        = "${var.prefix}-admin"
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir web",
      "mkdir scripts",
      "mkdir conf"
    ]
  }

  provisioner "file" {
    source      = "scripts/initial-script.sh"
    destination = "scripts/initial-script.sh"
  }
  provisioner "file" {
    source      = "web"
    destination = "~"
  }

  provisioner "file" {
    source      = "services/golangnews.service"
    destination = "conf/golangnews.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x scripts/initial-script.sh",
      "/bin/bash scripts/initial-script.sh",
      "sudo mv conf/golangnews.service /etc/systemd/system/golangnews.service",
      "sudo systemctl daemon-reload",
      "sudo service golangnews enable",
      "sudo service golangnews start"
    ]
  }

  tags = {
    env = "staging"
  }
}

resource "azurerm_virtual_machine_extension" "web" {
  name                 = "OmsAgentForLinux"
  virtual_machine_id   = azurerm_linux_virtual_machine.web.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.13"

  settings           = <<SETTINGS
    {
        "workspaceId": "${data.azurerm_log_analytics_workspace.main.workspace_id}"
    }
    SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${data.azurerm_log_analytics_workspace.main.primary_shared_key}"
    }
    PROTECTED_SETTINGS

  tags = {
    env = "staging"
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.prefix}-log-analytics-${random_id.randomId.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    env = "staging"
  }
}


resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "storageaccount_log" {
  name                     = "${var.prefix}log${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    env = "staging"
  }
}


resource "azurerm_postgresql_server" "main" {
  name                = "${var.postgresql_server_name}-${random_id.randomId.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "B_Gen5_1"

  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login           = var.postgresql_db_username
  administrator_login_password  = var.postgresql_db_password
  version                       = var.postgresql_version
  ssl_enforcement_enabled       = true
  public_network_access_enabled = true
}

resource "azurerm_postgresql_database" "main" {
  name                = "generaldb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.main.name
  charset             = var.postgresql_charset
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "home" {
  name                = "home"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.main.name
  start_ip_address    = var.allow_start_ip_address
  end_ip_address      = var.allow_end_ip_address
}


data "azurerm_public_ip" "nat" {
  name                = azurerm_public_ip.nat.name
  resource_group_name = azurerm_nat_gateway.main.resource_group_name
  depends_on          = [azurerm_nat_gateway.main]
}

output "nat_public_ip_address" {
  value = data.azurerm_public_ip.nat.ip_address
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.web.name
  resource_group_name = azurerm_linux_virtual_machine.web.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.web]
}


output "web_public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

data "azurerm_postgresql_server" "main" {
  name                = azurerm_postgresql_server.main.name
  resource_group_name = azurerm_postgresql_server.main.resource_group_name
}

output "postgresql_server_id" {
  value = data.azurerm_postgresql_server.main.id
}

data "azurerm_log_analytics_workspace" "main" {
  name                = azurerm_log_analytics_workspace.main.name
  resource_group_name = azurerm_log_analytics_workspace.main.resource_group_name
}

