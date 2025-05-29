variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "zone_id" {
  description = "Route53 zone ID for validation"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}