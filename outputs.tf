output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_url_http" {
  description = "HTTP endpoint"
  value       = "http://${aws_lb.main.dns_name}"
}

output "alb_url_https" {
  description = "HTTPS endpoint (self-signed certificate — use -k with curl)"
  value       = "https://${aws_lb.main.dns_name}"
}

output "vpc_endpoint_id" {
  description = "ID of the Konnect PrivateLink VPC Endpoint (null if enable_private_link = false)"
  value       = var.enable_private_link ? aws_vpc_endpoint.konnect[0].id : null
}

output "vpc_endpoint_dns_entries" {
  description = "DNS entries of the Konnect PrivateLink VPC Endpoint (empty if enable_private_link = false)"
  value       = var.enable_private_link ? aws_vpc_endpoint.konnect[0].dns_entry : []
}
