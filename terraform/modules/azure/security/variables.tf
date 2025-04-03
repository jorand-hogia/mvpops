variable "defender_plans_to_enable" {
  description = "Map of Defender for Cloud plans to enable and their tiers."
  type = map(object({
    tier = string
  }))
  default = {
    # Example: Enable Defender for Servers Plan 2 (Standard)
    # "VirtualMachines" = { tier = "Standard" }
    # Example: Enable Defender for Storage (Standard)
    # "StorageAccounts" = { tier = "Standard" }
    # Example: Enable Defender for Key Vault (Standard)
    # "KeyVaults" = { tier = "Standard" }
  }
  # Add descriptions for common plans
} 