resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "kong-dp"
      image = var.kong_image
      essential = true
      portMappings = [
        { containerPort = 8000, hostPort = 8000 },
        { containerPort = 8100, hostPort = 8100 }
      ]
      environment = [
        # --- Status API Settings ---
        { name = "KONG_STATUS_LISTEN", value = "0.0.0.0:8100" },
        # --- Base Kong DP Settings ---
        { name = "KONG_ROLE", value = "data_plane" },
        { name = "KONG_DATABASE", value = "off" },
        { name = "KONG_VITALS", value = "off" },
        { name = "KONG_CLUSTER_MTLS", value = "pki" },
        { name = "KONG_CLUSTER_CONTROL_PLANE", value = "${replace(data.konnect_gateway_control_plane.main.config.control_plane_endpoint, "/^https?:\\/\\//", "")}:443" },
        { name = "KONG_CLUSTER_SERVER_NAME", value = replace(data.konnect_gateway_control_plane.main.config.control_plane_endpoint, "/^https?:\\/\\//", "") },
        { name = "KONG_CLUSTER_TELEMETRY_ENDPOINT", value = "${replace(data.konnect_gateway_control_plane.main.config.telemetry_endpoint, "/^https?:\\/\\//", "")}:443" },
        { name = "KONG_CLUSTER_TELEMETRY_SERVER_NAME", value = replace(data.konnect_gateway_control_plane.main.config.telemetry_endpoint, "/^https?:\\/\\//", "") },
        { name = "KONG_LUA_SSL_TRUSTED_CERTIFICATE", value = "system" },
        { name = "KONG_KONNECT_MODE", value = "on" },
        { name = "KONG_CLUSTER_DP_LABELS", value = "type:ecs-fargate" },
        { name = "KONG_ROUTER_FLAVOR", value = "expressions" },
        { name = "KONG_CLUSTER_CERT", value = tls_self_signed_cert.dp_cert.cert_pem },
        { name = "KONG_CLUSTER_CERT_KEY", value = tls_private_key.dp_cert.private_key_pem },
        ## --- For Production ---
        { name = "KONG_ANONYMOUS_REPORTS", value = "off" },
        { name = "KONG_HEADERS", value = "off" },
        { name = "KONG_UNTRUSTED_LUA", value = "off" }

      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.public[*].id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "kong-dp"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.front_end]
}
