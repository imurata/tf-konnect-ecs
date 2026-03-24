# AWS PrivateLink for Konnect Control Plane connectivity
# Enabled by setting enable_private_link = true
#
# Prerequisites:
#   - Inbound TCP 443 allowed in security group (handled below)
#   - Private DNS enabled on the VPC endpoint (configured below)
#
# How it works:
#   When private_dns_enabled = true, the Konnect hostnames (e.g. *.cp.konghq.com)
#   resolve to the VPC endpoint's private IPs within the VPC — no changes to
#   Kong Data Plane environment variables are needed.
#
# Service names by region: https://developer.konghq.com/gateway/aws-private-link/

resource "aws_security_group" "vpc_endpoint" {
  count  = var.enable_private_link ? 1 : 0
  name   = "${var.app_name}-vpc-endpoint-sg"
  vpc_id = aws_vpc.main.id

  # Allow HTTPS from ECS tasks to the PrivateLink endpoint
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.app_name}-vpc-endpoint-sg" }
}

resource "aws_vpc_endpoint" "konnect" {
  count = var.enable_private_link ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = var.konnect_private_link_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.public[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint[0].id]
  private_dns_enabled = true

  tags = { Name = "${var.app_name}-konnect-endpoint" }

  lifecycle {
    precondition {
      condition     = can(regex("^com\\.amazonaws\\.vpce\\.", var.konnect_private_link_service_name))
      error_message = "konnect_private_link_service_name must be set to a valid AWS PrivateLink service name (e.g. 'com.amazonaws.vpce.ap-northeast-1.vpce-svc-xxx') when enable_private_link is true."
    }
  }
}
