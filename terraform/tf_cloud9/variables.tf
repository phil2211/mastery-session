variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "join_shared_vpc" {
  description = "Trigger to determine if we have to join  the shared VPC"
  type        = bool
  default     = false
}