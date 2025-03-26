# Define default tags to be used across all resources
locals {
  common_tags = {
    team        = var.team_name
    environment = var.environment
  }
}

variable "team_name" {
  description = "Name of the team owning the resource"
  type        = string
  default     = "mvpops"
} 