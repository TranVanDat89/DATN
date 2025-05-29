output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate_validation.cert.certificate_arn
}

output "certificate_domain_validation_options" {
  description = "Certificate domain validation options"
  value       = aws_acm_certificate.cert.domain_validation_options
}