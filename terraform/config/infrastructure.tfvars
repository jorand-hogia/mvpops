# Deployment Control
deployment = {
  environments = {
    dev = {
      enabled = false  # Set to true when ready to deploy dev environment
    }
    prod = {
      enabled = true   # Always enabled for production
    }
  }
}

# Resource Group Configuration
resource_group = {
  name     = "gunnar-test"  # Name of the resource group
  location = "swedencentral"           # Azure region for the resource group
}

# Server Scheduling
scheduling = {
  office_hours = {
    timezone    = "Europe/Stockholm"  # Timezone for scheduling
    start_time  = "08:00"            # Office hours start (24h format)
    end_time    = "17:00"            # Office hours end (24h format)
    weekdays    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  }
  servers = {
    app_server = {
      auto_shutdown = true    # Enable auto-shutdown
      start_delay   = 15      # Minutes before office hours to start
      stop_delay    = 15      # Minutes after office hours to stop
    }
    db_server = {
      auto_shutdown = true    # Enable auto-shutdown
      start_delay   = 15      # Minutes before office hours to start
      stop_delay    = 15      # Minutes after office hours to stop
    }
    bastion = {
      auto_shutdown = false   # Keep bastion running 24/7
      start_delay   = 0       # No delay needed
      stop_delay    = 0       # No delay needed
    }
  }
}

# Network Configuration
network = {
  vnet_name           = "vnet-${var.environment}"
  vnet_address_space  = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
  subnet_names        = ["subnet-app", "subnet-db"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

# IP Address Configuration
ip_addresses = {
  app_server = {
    private_ip = "10.0.1.10"  # Static private IP for app server
    public_ip  = ""           # Leave empty for no public IP
  }
  db_server = {
    private_ip = "10.0.2.10"  # Static private IP for db server
    public_ip  = ""           # Leave empty for no public IP
  }
  bastion = {
    private_ip = "10.0.3.10"  # Static private IP for bastion
    public_ip  = "20.0.0.10"  # Static public IP for bastion
  }
}

# Firewall Configuration
firewall = {
  name                = "fw-${var.environment}"
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  public_ip_name      = "pip-fw-${var.environment}"
  rules = {
    allow_http = {
      name             = "AllowHTTP"
      priority         = 100
      action          = "Allow"
      source_addresses = ["*"]
      destination_addresses = ["*"]
      destination_ports = ["80", "443"]
      protocols       = ["TCP"]
    }
    allow_ssh = {
      name             = "AllowSSH"
      priority         = 110
      action          = "Allow"
      source_addresses = ["10.0.0.0/16"]
      destination_addresses = ["*"]
      destination_ports = ["22"]
      protocols       = ["TCP"]
    }
  }
}

# Server Configuration
servers = {
  app_server = {
    name              = "vm-app-${var.environment}"
    size              = "Standard_B1s"
    os_disk_type      = "Premium_LRS"
    admin_username    = var.vm_admin_username
    subnet_name       = "subnet-app"
    private_ip        = var.ip_addresses.app_server.private_ip
    public_ip         = var.ip_addresses.app_server.public_ip
    custom_data       = filebase64("${path.module}/scripts/app-server-setup.sh")
  }
  db_server = {
    name              = "vm-db-${var.environment}"
    size              = "Standard_E2s_v3"
    os_disk_type      = "Premium_LRS"
    admin_username    = var.vm_admin_username
    subnet_name       = "subnet-db"
    private_ip        = var.ip_addresses.db_server.private_ip
    public_ip         = var.ip_addresses.db_server.public_ip
    custom_data       = filebase64("${path.module}/scripts/db-server-setup.sh")
  }
  bastion = {
    name              = "vm-bastion-${var.environment}"
    size              = "Standard_B1s"
    os_disk_type      = "Premium_LRS"
    admin_username    = var.vm_admin_username
    subnet_name       = "subnet-bastion"
    private_ip        = var.ip_addresses.bastion.private_ip
    public_ip         = var.ip_addresses.bastion.public_ip
    custom_data       = filebase64("${path.module}/scripts/bastion-setup.sh")
  }
}

# Monitoring Configuration
monitoring = {
  log_analytics_workspace = {
    name              = "law-${var.environment}"
    sku               = "PerGB2018"
    retention_in_days = 30
  }
  application_insights = {
    name              = "appi-${var.environment}"
    application_type  = "web"
  }
}

# Backup Configuration
backup = {
  vault_name         = "rsv-${var.environment}"
  sku                = "Standard"
  retention_days     = 30
  backup_policies = {
    vm_backup = {
      name           = "vm-backup-policy"
      frequency      = "Daily"
      time           = "23:00"
      retention_days = 30
    }
  }
} 