# Initial FQDN Discovery
data "http" "ctrl_auth" {
  provider             = http-full
  url                  = "https://${var.ctrl_ip}/v2/api"
  method               = "POST"
  insecure_skip_verify = false
  request_headers = {
    content-type = "application/json"
  }
  request_body = jsonencode({
    username = var.ctrl_username,
    password = var.ctrl_password,
    action   = "login"
  })
}

data "http" "fqdn_discovery" {
  provider             = http-full
  url                  = "https://${var.ctrl_ip}/v2/api"
  method               = "POST"
  insecure_skip_verify = false
  request_headers = {
    content-type = "application/x-www-form-urlencoded"
  }
  request_body = "action=${local.avx_egress ? "start_fqdn_discovery" : "stop_fqdn_discovery"}&gateway_name=${aviatrix_gateway.egress.gw_name}&CID=${jsondecode(data.http.ctrl_auth.response_body).CID}"
}
