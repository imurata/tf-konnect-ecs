# https://registry.terraform.io/providers/Kong/konnect/latest/docs
data "konnect_gateway_control_plane" "main" {
  filter = {
    name = {
      eq = var.konnect_control_plane_name
    }
  }
}

resource "tls_private_key" "dp_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "dp_cert" {
  private_key_pem = tls_private_key.dp_cert.private_key_pem

  subject {
    common_name  = "kong-dp"
    organization = "Kong Inc."
  }

  validity_period_hours = 87600 # 10 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

# https://registry.terraform.io/providers/Kong/konnect/latest/docs/resources/gateway_data_plane_client_certificate
resource "konnect_gateway_data_plane_client_certificate" "dp_cert" {
  control_plane_id = data.konnect_gateway_control_plane.main.id
  cert             = tls_self_signed_cert.dp_cert.cert_pem
}
