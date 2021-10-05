resource "tfe_agent_pool" "this" {
  name         = "global-core-agent-pool"
  organization = var.tfc_organization
}

resource "tfe_agent_token" "this" {
  agent_pool_id = tfe_agent_pool.this.id
  description   = "this-agent-token"
}


resource "tls_private_key" "tfc_agent" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "template_file" "tfc_agent_user_data" {
  template = file("${path.module}/resources/tfc_agent_user_data.sh")

   vars = {
    TFC_AGENT_TOKEN = tfe_agent_token.this.token
    TFC_ADDRESS     = "https://app.terraform.io"
    TFC_AGENT_NAME  = "myAgent"
   }
}

resource "azurerm_linux_virtual_machine_scale_set" "tfc_agent" {
  name                = "tfc-agent"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard_F2s_v2"
  instances           = 2
  admin_username      = "vpostadmin"
  custom_data         = base64encode(data.template_file.tfc_agent_user_data.rendered)
  upgrade_mode        = "Automatic"

  tags = {
    chargebackModel = "SHARED_INFRA"
  }

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.owner.id]
  }

  admin_ssh_key {
    username   = "tfcadmin"
    public_key = tls_private_key.tfc_agent.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "tfc-agent-nic"
    primary = true

    ip_configuration {
      name      = "tfc-agent-ipconfig"
      primary   = true
      subnet_id = azurerm_subnet.vmss.id # subnet must already exist
    }
  }
}
