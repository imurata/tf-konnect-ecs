variable "region" {
  description = "AWS region"
  default     = "ap-northeast-1"
}

variable "app_name" {
  description = "Application name"
  default     = "kong-dp"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for ALB inbound traffic"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  default     = "512"
}

variable "ecs_task_memory" {
  description = "Memory for the ECS task"
  default     = "1024"
}

variable "kong_image" {
  description = "Docker image for Kong Gateway"
  default     = "kong/kong-gateway:latest"
}

variable "konnect_personal_access_token" {
  description = "Konnect Personal Access Token"
  type        = string
  sensitive   = true
}

variable "konnect_control_plane_name" {
  description = "Name of the Konnect Control Plane"
  type        = string
  default     = "default"
}
