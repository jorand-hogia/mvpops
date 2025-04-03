resource "azurerm_security_center_subscription_pricing" "defender_plans" {
  for_each     = var.defender_plans_to_enable
  tier         = each.value.tier
  resource_type = each.key
}

# Add other security-related resources here as needed, 
# e.g., azurerm_security_center_setting, azurerm_security_center_auto_provisioning 