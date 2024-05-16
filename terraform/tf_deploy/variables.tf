variable "domain_name" {
  type        = string
  description = "The domain name for the API Gateway"
  default     = "icp.corproot.net"
}

variable "region" {
  type = string
  description = "value of the region"
  default = "eu-central-1"
}

variable "certificate_authority_arn" {
  description = "ARN of the private CA"
  type        = string
  default     = "arn:aws:acm-pca:eu-central-1:276022440411:certificate-authority/69134a41-2898-410d-bede-977ea45d8d3b"
}

